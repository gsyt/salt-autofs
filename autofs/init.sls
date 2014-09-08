include:
  - autofs.installed

autofs:
  require:
    - sls: autofs.installed
