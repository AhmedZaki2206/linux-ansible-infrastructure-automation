# Hands-on Labs

نفذ labs بالترتيب على disposable VMs فقط.

## Lab 1: Inventory

```bash
ansible-inventory -i inventory/lab/hosts.yml --graph
ansible-inventory --host web01
```

تأكد إن web01 داخل `web_servers` و`lab_servers` وإن variables merged صح.

## Lab 2: Connectivity

```bash
ansible lab_servers -m ping
ansible lab_servers -m setup -a 'filter=ansible_distribution*'
```

عند `UNREACHABLE` راجع VM، key، host key، IP وUFW.

## Lab 3: User management

```bash
ansible lab_servers -b -m getent -a 'database=passwd key=ansible'
ansible lab_servers -b -m command -a 'id ansible'
```

راجع groups وshell، وتأكد إن password locked.

## Lab 4: SSH hardening

```bash
ansible-playbook site.yml --tags ssh --check --diff
ansible-playbook site.yml --tags ssh
ssh -o BatchMode=yes ansible@192.168.56.11 true
```

ما تقفلش session الحالية قبل فتح session ثانية ناجحة.

## Lab 5: Firewall

```bash
ansible-playbook site.yml --tags firewall
ansible lab_servers -b -m command -a 'ufw status verbose'
```

قارن web01 مع app01: HTTP rule لازم تكون على web01 فقط.

## Lab 6: Nginx/systemd

```bash
ansible-playbook site.yml --tags nginx
curl http://192.168.56.11/healthz
ansible web_servers -b -m command -a 'systemctl is-enabled nginx'
```

المتوقع `healthy` و`enabled`.

## Lab 7: Templates وhandlers

غيّر نص آمن في `index.html.j2`، نفذ `--tags nginx --diff`، وشاهد changed tasks. نفذ مرة ثانية؛ المفروض changed=0.

## Lab 8: Health timer وlogs

```bash
ansible lab_servers -b -m command -a 'systemctl start ansible-lab-health.service'
make logs HOST=ops01
```

راجع hostname، uptime، disk وmemory output.

## Lab 9: Backup/restore

```bash
make backup HOST=ops01
make restore HOST=ops01 ARCHIVE=/var/backups/ansible-lab/<archive>.tar.gz
```

عدل نسخة من archive لاختبار checksum failure. لا تعدل live config.

## Lab 10: Idempotency

```bash
make configure
make idempotency
```

اشرح ليه `command` يحتاج `changed_when: false` لو read-only.

## Lab 11: SSH incident

اعمل syntax error في نسخة مؤقتة من drop-in وشغل `sshd -t -f <file>`؛ لاحظ إنه يمنع apply. لا تستبدل config الحقيقي. تمرن على recovery بـ `vagrant ssh`.

## Lab 12: Nginx incident

```bash
vagrant ssh web01
sudo systemctl stop nginx
sudo /usr/local/sbin/ansible-lab-health || true
sudo journalctl -u nginx -n 50
exit
ansible-playbook site.yml --tags nginx
```

ثبت detection ثم recovery.

## Lab 13: Disk pressure

استخدم `df -h`, `du -xhd1 /var`, وراجع logs/backups. لا تملأ disk عمدًا على جهازك الحقيقي.

## Lab 14: Container limitation

شغل Compose connectivity playbook، ثم حاول `systemctl` ولاحظ الفرق. اشرح ليه VM أفضل لهذا المشروع.

## Lab 15: CI failure

في branch تجريبي اكسر indentation في YAML، شغل `yamllint` محليًا ثم أصلحه قبل push. راجع PR checks.

