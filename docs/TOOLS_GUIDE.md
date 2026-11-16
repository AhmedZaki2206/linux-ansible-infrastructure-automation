# دليل الـ Tools: التثبيت والاستخدام داخل المشروع

الدليل ده يشرح الأدوات المستخدمة فعلًا في المشروع. الأوامر تتنفذ من Ubuntu داخل WSL2 إلا لو مكتوب PowerShell. `Helm` غير مستخدم هنا لأن Helm package manager لـ Kubernetes، والمشروع الحالي بيدير Ubuntu VMs مباشرة باستخدام Ansible.

## 1. WSL2

**دوره:** يوفر Linux environment على Windows لتشغيل Python، Ansible، Bash، Make وSSH.

PowerShell كـ Administrator:

```powershell
wsl --install -d Ubuntu
wsl --update
wsl --status
```

بعد restart افتح Ubuntu:

```bash
sudo apt update
sudo apt install -y git make curl openssh-client python3 python3-venv python3-pip
```

**Validation:** `uname -a` و`python3 --version`. لو `wsl` غير معروف، حدّث Windows وفعّل Virtual Machine Platform من Windows Features.

## 2. Git وGitHub

**دوره:** version control، feature branch، Pull Request، وتشغيل GitHub Actions.

```bash
git --version
git config --global user.name "Ahmed Zaki"
git config --global user.email "YOUR_GITHUB_EMAIL"
git clone https://github.com/AhmedZaki2206/linux-ansible-infrastructure-automation.git
cd linux-ansible-infrastructure-automation
git switch feature/linux-ansible-automation
```

المشروع استخدم branch منفصل ومفيش force push أو merge تلقائي. راجع التغييرات بـ `git status`, `git diff`, و`git log --oneline`.

## 3. Python virtual environment وpip

**دوره:** Ansible مكتوب بـ Python. الـ venv يعزل versions المشروع عن system Python.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements-dev.txt
```

`requirements-dev.txt` يثبت `ansible-core`, `ansible-lint`, و`yamllint` بنسخ محددة. كل مرة تفتح terminal:

```bash
cd ~/projects/linux-ansible-infrastructure-automation
source .venv/bin/activate
```

**Validation:** `which ansible` لازم يشير إلى `.venv/bin/ansible`.

## 4. Ansible

**دوره:** يحول desired state في YAML إلى إعداد متكرر وآمن على `web01`, `app01`, و`ops01` عبر SSH.

```bash
ansible --version
ansible-galaxy collection install -r requirements.yml
ansible-inventory -i inventory/lab/hosts.yml --graph
ansible -i inventory/lab/hosts.yml lab_servers -m ansible.builtin.ping
ansible-playbook -i inventory/lab/hosts.yml site.yml
```

كيف استخدمناه:

- `ansible.builtin.apt` للحزم بدل `apt` داخل shell.
- `user`, `group`, و`authorized_key` لإدارة الحساب والـ SSH key.
- `template` لإنشاء Nginx، SSH، systemd، logrotate وBash scripts.
- `systemd_service` لتفعيل وتشغيل الخدمات.
- `community.general.ufw` للfirewall.
- handlers لreload فقط عند تغير config.
- `assert` وpreflight لإيقاف التنفيذ قبل lockout.

**Useful flags:**

```bash
ansible-playbook site.yml --check --diff
ansible-playbook site.yml --tags nginx
ansible-playbook site.yml --limit web01
ansible-playbook site.yml -vv
```

`--check` prediction مش ضمان كامل، وtasks الشبكة والأمان لازم تتراجع قبل apply.

## 5. Ansible Galaxy Collections

**دورها:** توفر modules مدعومة مش موجودة في `ansible-core`.

```bash
ansible-galaxy collection install -r requirements.yml
ansible-galaxy collection list
```

المشروع يستخدم `ansible.posix.authorized_key` و`community.general.ufw/timezone`. النسخ مثبتة في `requirements.yml` عشان reproducibility.

## 6. YAML وyamllint

**دوره:** YAML هو format للinventory والplaybooks والvariables. المسافات مهمة ومفيش tabs.

```bash
yamllint .
```

الإعداد في `.yamllint`. لو ظهر syntax error راجع indentation ومكان `---` والقيم اللي محتاجة quotes.

## 7. ansible-lint

**دوره:** يراجع Ansible best practices: FQCN، أسماء tasks، idempotency، permissions وshell usage.

```bash
ansible-lint
ansible-lint roles/ssh_hardening
```

إعداد profile موجود في `.ansible-lint`. ما نستخدمش `skip_list` لإخفاء مشاكل من غير سبب.

## 8. OpenSSH

**دوره:** transport بين controller والtargets. المشروع يستخدم Ed25519 key ومفيش password في Git.

```bash
ssh-keygen -t ed25519 -a 64 -f ~/.ssh/ansible_lab_ed25519 -N ''
ssh -i ~/.ssh/ansible_lab_ed25519 ansible@192.168.56.11
ssh-keyscan -H -t ed25519 192.168.56.11 >> ~/.ssh/known_hosts
```

`bootstrap.sh` يعمل ده تلقائيًا لو key مش موجود. `preflight.yml` يتأكد إن نفس public key داخل `authorized_keys` قبل `PasswordAuthentication no`.

## 9. VirtualBox

**دوره:** hypervisor يشغل 3 Ubuntu VMs حقيقية، وبالتالي نختبر systemd وUFW وSSH بصورة أقرب للسيرفر.

نزّله على Windows من الموقع الرسمي، ثم:

```powershell
VBoxManage --version
```

الـ `Vagrantfile` يطلب host-only IPs من `192.168.56.11` إلى `.13`. لو Hyper-V أو corporate policy عمل conflict، راجع VirtualBox Host Network Manager أو استخدم native Linux host.

## 10. Vagrant

**دوره:** يعرّف ويعيد إنشاء الـ VMs من `Vagrantfile` بدل manual clicks.

```bash
vagrant --version
vagrant validate
vagrant up
vagrant status
vagrant ssh web01
vagrant destroy --force
```

في المشروع:

- `make lab-up` يستدعي `vagrant up`.
- `make bootstrap` يستخدم `vagrant ssh` كـ recovery/bootstrap channel قبل Ansible.
- `make lab-down` يحذف VMs الخاصة بالمشروع فقط.

## 11. Make

**دوره:** واجهة قصيرة وثابتة للcommands الطويلة.

```bash
make help
make install
make lint
make syntax
make lab-up
make bootstrap
make configure
make test
make idempotency
make backup HOST=ops01
make lab-down
```

Make لا ينفذ logic الأمن بنفسه؛ هو يستدعي scripts تحت `scripts/`.

## 12. Bash

**دوره:** lifecycle automation، health check، backup وstaged restore.

كل script يبدأ بـ:

```bash
set -Eeuo pipefail
```

ده يخلي script يقف عند command فاشل، variable غير معرف، أو pipeline failure. افحص syntax:

```bash
bash -n scripts/*.sh
```

ملفات `roles/common/templates/health-check.sh.j2` و`roles/backup/templates/*.j2` templates؛ Ansible يحولها إلى scripts على السيرفر.

## 13. Nginx

**دوره:** web service على `web01` فقط.

```bash
curl http://192.168.56.11/
curl http://192.168.56.11/healthz
ansible web_servers -b -m command -a 'nginx -t'
```

الـ role يثبت package، ينشئ site، يلغي default site، يعمل reload بالhandler، ويتأكد من HTTP 200. الوصول مسموح داخل lab CIDR فقط.

## 14. systemd وjournalctl

**دوره:** يدير `ssh`, `nginx` وhealth timer.

```bash
systemctl status nginx
systemctl list-timers ansible-lab-health.timer
journalctl -u nginx --since today
journalctl -u ansible-lab-health.service -n 50
```

Containers العادية لا تشغل booted systemd، وده سبب إن VMs هي المسار الأساسي.

## 15. UFW

**دوره:** firewall frontend على Ubuntu.

```bash
sudo ufw status verbose
sudo ufw status numbered
```

الترتيب الأمني في المشروع: allow SSH من `controller_cidr`، allow HTTP للweb group، default deny incoming، وبعدها enable. لو حصل خطأ استخدم `vagrant ssh` كconsole recovery بدل تجربة rules عشوائيًا.

## 16. logrotate

**دوره:** يمنع health log من النمو بلا حدود.

```bash
sudo logrotate --debug /etc/logrotate.d/ansible-lab-health
```

الإعداد يعمل weekly rotation، يحتفظ بأربع نسخ، ويضغط النسخ القديمة.

## 17. tar وsha256sum

**دورهما:** إنشاء configuration backup والتحقق إنه لم يتغير.

```bash
make backup HOST=ops01
sudo sha256sum --check /var/backups/ansible-lab/<archive>.sha256
make restore HOST=ops01 ARCHIVE=/var/backups/ansible-lab/<archive>.tar.gz
```

الrestore يفك في `/tmp` للمراجعة ولا يكتب فوق live config. ده يقلل خطر استرجاع archive غلط.

## 18. Docker Compose: البديل الخفيف

**دوره:** يعمل 3 SSH containers بسرعة لاختبار controller connectivity فقط.

```bash
docker compose -f containers/compose.yml up --build -d
ansible-playbook -i inventory/containers/hosts.yml playbooks/container-connectivity.yml
docker compose -f containers/compose.yml down
```

القيود: لا systemd boot حقيقي، UFW behavior غير مماثل، والـ full `site.yml` غير مدعوم.

## 19. GitHub Actions

**دوره:** static validation على Pull Request بدون SSH أو VMs.

`.github/workflows/validate.yml` يعمل checkout، Python setup، dependency install، collection install، yamllint، ansible-lint وsyntax check. الصلاحية `contents: read` فقط. مفيش `ansible-playbook site.yml` deployment ولا secrets.

## هل نحتاج Helm أو kubectl؟

لا. `Helm` و`kubectl` أدوات Kubernetes، والمشروع ده يدير Linux servers مباشرة. إضافتهم هتزود تعقيد من غير استخدام حقيقي. لو مشروع Kubernetes منفصل، Helm يثبت charts و`kubectl` يتعامل مع cluster، لكنهم خارج scope المشروع الحالي.

## ترتيب التعلم المقترح

1. Linux filesystem/users/permissions وSSH.
2. Git وYAML.
3. Vagrant/VirtualBox networking.
4. Ansible inventory وad-hoc commands.
5. Playbooks، variables، templates، handlers وroles.
6. UFW وSSH safety.
7. Nginx/systemd/logrotate.
8. Backups وidempotency.
9. Linters وGitHub Actions.

