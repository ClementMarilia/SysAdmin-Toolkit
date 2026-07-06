# SysAdmin Toolkit

**SysAdmin Toolkit** is a PowerShell desktop tool for Windows Server daily administration.

The goal is to provide a simple, multilingual and safe interface for common IT support and sysadmin checks.

## Languages

- Italian
- Portuguese
- English
- Spanish

Default language: **Italian**.

## Current version

### V1 Base

Included features:

- Dashboard base
- Server information
- Network information
- DNS test
- Running services
- Stopped services
- Disk usage
- Last system errors
- Export output to TXT

No destructive actions are included in V1.

## Project structure

```text
SysAdmin-Toolkit
├── app.ps1
├── config.json
├── lang
│   ├── it.json
│   ├── pt.json
│   ├── en.json
│   └── es.json
└── modules
    ├── ServerInfo.psm1
    ├── NetworkTools.psm1
    ├── ServiceTools.psm1
    ├── StorageTools.psm1
    ├── EventTools.psm1
    └── ExportTools.psm1
```

## How to run

Open PowerShell as Administrator:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\app.ps1
```

## Roadmap

### V2

- Active Directory checks
- Process monitoring
- HTML export
- Better dashboard cards

### V3

- Veeam checks
- RMM agent checks
- Health score

### V4

- Smart diagnosis
- Recommendations
- Report generation
