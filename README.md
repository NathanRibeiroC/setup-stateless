# setup-stateless

Projeto base para automatizar setup de maquina Ubuntu de forma idempotente e sem estado local complexo.

## Objetivo

Provisionar ferramentas de desenvolvimento e preferencias essenciais usando script versionado.

## Estrutura

- `scripts/bootstrap.sh`: instala dependencias basicas e configura o ambiente.
- `scripts/check.sh`: valida comandos essenciais apos setup.

## Uso

```bash
bash scripts/bootstrap.sh
bash scripts/check.sh
```

## Observacoes

- O script foi pensado para Ubuntu.
- Execute com usuario com permissao de `sudo`.
