# دليل التنفيذ خطوة بخطوة

## 1. تجهيز Windows 11

PowerShell Administrator:

```powershell
wsl --install -d Ubuntu
wsl --update
```

ثبت VirtualBox وVagrant على Windows، ثم تحقق بـ `VBoxManage --version` و`vagrant --version`. لو WSL لا يرى executables استخدم PowerShell/Git Bash لتشغيل Vagrant، أو native Linux. لا تستخدم nested virtualization غير مستقرة.

داخل Ubuntu:

```bash
sudo apt update
sudo apt install -y git make curl openssh-client python3 python3-venv python3-pip
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/AhmedZaki2206/linux-ansible-infrastructure-automation.git
cd linux-ansible-infrastructure-automation
python3 -m venv .venv
source .venv/bin/activate
make install
```

**Validation:** `ansible --version`, `yamllint --version`, `ansible-lint --version`.

## 2. Static checks قبل أي VM

```bash
make lint
make syntax
vagrant validate
bash -n scripts/*.sh
```

الهدف اكتشاف YAML، best-practice، syntax وBash errors من غير تغيير infrastructure.

## 3. إنشاء الـ lab

```bash
make lab-up
vagrant status
```

المتوقع `web01`, `app01`, `ops01` بحالة running. لو box download فشل راجع الإنترنت؛ لو IP conflict غيّر الشبكة في Vagrantfile وinventory/group vars معًا.

## 4. Bootstrap الآمن

```bash
make bootstrap
```

الـ script ينشئ Ed25519 key محليًا، يدخل من Vagrant recovery channel، ينشئ user `ansible`، يثبت public key وbootstrap sudoers، يحدث `known_hosts` ثم يعمل Ansible ping. الـ private key لا يخرج من controller.

Validation يدوي:

```bash
ssh -i ~/.ssh/ansible_lab_ed25519 ansible@192.168.56.11
ansible-inventory --graph
ansible lab_servers -m ansible.builtin.ping
```

## 5. Preview ثم configure

```bash
ansible-playbook site.yml --check --diff
make configure
```

`--check` preview وليس ضمانًا. التنفيذ يبدأ preflight؛ لو key/sudo غير آمن يتوقف قبل SSH/UFW. بعد النجاح راجع play recap لكل host.

## 6. Verification

```bash
make test
make status
curl -i http://192.168.56.11/healthz
ansible web_servers -b -m command -a 'nginx -t'
ansible lab_servers -b -m command -a 'ufw status verbose'
```

المتوقع ping success، SSH BatchMode success، `/healthz` = 200، والخدمات active.

## 7. Idempotency

شغل configure مرة أولى، ثم:

```bash
make idempotency
```

الـ script يفشل لو أي recap فيه `changed` أكبر من صفر. لو فشل استخدم `ansible-playbook site.yml -vv` وحدد task غير idempotent.

## 8. Backup وrestore

```bash
make backup HOST=ops01
make restore HOST=ops01 ARCHIVE=/var/backups/ansible-lab/<archive>.tar.gz
```

Backup ينشئ archive و`.sha256`. Restore يتحقق من checksum ويفك تحت `/tmp` فقط. راجع الملفات قبل أي manual copy للlive config.

## 9. Logs وincident checks

```bash
make logs HOST=web01
vagrant ssh web01
sudo journalctl -u ssh -u nginx -n 100
sudo systemctl list-timers ansible-lab-health.timer
sudo ufw status numbered
```

SSH lockout: استخدم `vagrant ssh`, راجع drop-in وrestore backup. Nginx: `nginx -t`. UFW: أعد allow rule للcontroller قبل enable.

## 10. Cleanup وإعادة البناء

```bash
make lab-down
make lab-up
make bootstrap
make configure
make test
```

`lab-down` يحذف VMs الخاصة بالمشروع؛ لا يحذف Git repo أو SSH key. لحذف key يدويًا لازم تتأكد إنه خاص بالlab.

## 11. GitHub Actions

على PR، workflow يعمل yamllint وansible-lint وsyntax فقط. لا يتصل بالVMs. نجاح CI لا يساوي نجاح integration lab؛ سجل VM tests منفصلة وبصدق.

## Beginner learning path

ابدأ Linux permissions وSSH، ثم YAML/inventory، بعدها ad-hoc modules، playbooks/variables، templates/handlers، roles، UFW/sshd safety، systemd/logrotate، وأخيرًا idempotency وCI.

