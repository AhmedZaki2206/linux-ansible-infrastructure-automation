# Interview Preparation

## 60-second summary

**English:** “I built a personal Ansible portfolio lab that manages three private Ubuntu VMs: web, application, and operations nodes. Vagrant and VirtualBox provide realistic SSH, systemd, and firewall behavior. Ansible uses seven reusable roles for baseline packages, users, SSH hardening, UFW, Nginx, logging, and validated backups. Safety checks verify key access and sudo before disabling passwords, and SSH/firewall changes preserve controller connectivity. Pull requests run YAML, Ansible lint, and syntax checks without touching infrastructure. I also test connectivity, HTTP health, backup restore, and second-run idempotency locally. It is a learning lab, not production experience.”

## 5-minute structure

اشرح بالترتيب: المشكلة، 3 VMs/private network، inventory/variables، bootstrap/preflight، roles/handlers، SSH/UFW safety، Nginx/systemd، backup staging، idempotency، CI validation، limitations والدروس.

**English opening:** “The design separates provisioning from configuration. Vagrant creates disposable servers, while Ansible owns desired state. I deliberately use VMs rather than containers for the primary path because systemd, SSH daemon reloads, and UFW need realistic operating-system behavior.”

## 40 Q&A

كل إجابة فيها المختصر ثم Sample English Answer.

1. **What is Ansible?** Agentless desired-state automation over SSH. “Ansible applies declarative tasks over SSH without a permanent target agent.”
2. **Why inventory groups?** لتطبيق variables/roles حسب الوظيفة. “Groups let me target shared baselines and web-specific configuration cleanly.”
3. **What is idempotency?** نفس التشغيل لا يعمل changes غير لازمة. “A second run should report zero unexpected changes.”
4. **Playbook vs role?** playbook orchestration؛ role reusable unit. “The playbook orders work; roles package tasks, defaults, templates, and handlers.”
5. **Why handlers?** reload فقط عند change. “Handlers prevent unnecessary service reloads.”
6. **Why templates?** config dynamic من variables. “Jinja templates create host-specific validated configuration.”
7. **group_vars vs host_vars?** shared group settings مقابل host override. “I keep common policy in group variables and node-specific context in host variables.”
8. **Why built-in modules?** idempotency وstructured errors. “Modules are safer and more predictable than arbitrary shell commands.”
9. **When use command?** لما مفيش module، مع changed_when. “I use command for read-only validation and explicitly mark it unchanged.”
10. **What does become do?** privilege escalation. “The controller connects as ansible and elevates only for privileged tasks.”
11. **Why NOPASSWD ALL here?** general modules تحتاج privileged Python؛ lab-only limitation. “It is isolated to disposable VMs and is not a production least-privilege claim.”
12. **How avoid SSH lockout?** key/sudo preflight، allow rule، validate config، keep recovery. “I verify access before hardening and retain Vagrant console recovery.”
13. **Why `sshd -t`?** يمنع invalid config. “The template is validated before installation or reload.”
14. **Why disable root/password SSH?** يقلل attack paths. “The lab uses a named key-only automation identity.”
15. **What is host-key checking?** يمنع impersonation. “Known-host verification detects unexpected server identity changes.”
16. **Why refresh known_hosts carefully?** ممكن يخفي MITM. “I refresh only after deliberately recreating disposable VMs.”
17. **UFW order?** allow SSH before enable/default deny. “Connectivity-preserving rules are created before firewall activation.”
18. **Why private network?** يمنع exposure. “Targets are reachable only on the host-only lab network.”
19. **Why Vagrant?** reproducible VM lifecycle. “The Vagrantfile recreates consistent nodes without manual GUI steps.”
20. **Why VMs over containers?** systemd/UFW/sshd realism. “Containers are only a lightweight connectivity alternative.”
21. **What does systemd do?** service/timer lifecycle. “It enables Nginx and schedules health checks.”
22. **Why health endpoint?** verify service not just process. “`/healthz` gives a simple HTTP-level check.”
23. **Why Nginx handler validates first?** avoid broken reload. “`nginx -t` gates the reload.”
24. **What is logrotate?** rotate/compress/retain logs. “It controls disk growth for the health log.”
25. **Backup validation?** tar list + SHA-256. “The script validates archive structure and writes a checksum.”
26. **Why staged restore?** avoid overwriting live config. “Restore extracts under `/tmp` for review and refuses `/`.”
27. **What does `--check --diff` do?** preview differences. “It is useful but not a guarantee for every module.”
28. **What are tags?** selective execution. “Tags let me run only SSH, firewall, or Nginx work.”
29. **What is `--limit`?** target subset. “I can safely test a change on web01 first.”
30. **How debug UNREACHABLE?** VM/IP/key/host key/firewall. “I move from network reachability to SSH identity and firewall evidence.”
31. **How debug sudo failure?** console + sudoers validation. “I use Vagrant recovery and `visudo -cf`.”
32. **How debug Nginx?** nginx -t, systemctl, journalctl, curl. “I validate config, service state, logs, then HTTP.”
33. **How debug changed every run?** `-vv`, diff، inspect task/module. “I locate the changing task and correct desired-state logic.”
34. **What does ansible-lint add?** Ansible best practices. “It catches risky shell usage, naming, permissions, and idempotency patterns.”
35. **What does yamllint add?** YAML syntax/style. “It catches indentation and formatting before Ansible parsing.”
36. **What does CI run?** static lint/syntax only. “CI never receives SSH credentials or contacts infrastructure.”
37. **Why least-privilege token?** GitHub only needs read. “The workflow declares `contents: read`.”
38. **Where are secrets?** no secrets committed; local key only. “The repository references a local key path and stores no private material.”
39. **Project limitations?** disposable lab، no HA/TLS/central logs. “I document what is not production-ready instead of overstating it.”
40. **Next improvements?** Vault، Molecule VM driver، encrypted off-host backup، controlled patching. “I would add them only with tests and clear requirements.”

## Practice method

نفذ كل lab، اشرح architecture من غير قراءة، اعمل failure آمن واجمع evidence، ثم جاوب بالإنجليزي باستخدام “I implemented this in a personal lab” وليس “in production”.

