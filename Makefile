.PHONY: help install lint syntax lab-up bootstrap configure test idempotency status logs backup restore lab-down

INVENTORY ?= inventory/lab/hosts.yml
HOST ?= ops01
ARCHIVE ?=

help:
	@echo "Targets: install lint syntax lab-up bootstrap configure test idempotency status logs backup restore lab-down"

install:
	python3 -m pip install -r requirements-dev.txt
	ansible-galaxy collection install -r requirements.yml

lint:
	yamllint .
	ansible-lint

syntax:
	ansible-playbook -i $(INVENTORY) site.yml --syntax-check

lab-up:
	./scripts/lab-up.sh

bootstrap:
	./scripts/bootstrap.sh

configure:
	./scripts/configure.sh

test:
	./scripts/test.sh

idempotency:
	./scripts/idempotency-test.sh

status:
	./scripts/status.sh

logs:
	./scripts/logs.sh $(HOST)

backup:
	./scripts/backup.sh $(HOST)

restore:
	./scripts/restore.sh $(HOST) $(ARCHIVE)

lab-down:
	./scripts/lab-down.sh

