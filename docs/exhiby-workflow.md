# DevOps Workflow: Exhiby Deployment

## Übersicht

Vollständiger CI/CD Workflow für das Exhiby Museum CMS mit automatisierten Security-Updates, Tests und kontrolliertem Deployment.

---

## Workflow Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Dependabot     │     │  Security Fix   │     │  Feature Dev    │
│  Alert          │ or  │  PR (von mir)   │ or  │  PR (von dir)   │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         └───────────────────────┴───────────────────────┘
                                 │
                                 ▼
                    ┌─────────────────────┐
                    │  GitHub Actions CI  │
                    │  • RSpec Tests      │
                    │  • Brakeman Scan    │
                    │  • Rubocop Lint     │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
              ❌ Tests fail            ✅ Tests pass
                    │                     │
                    ▼                     ▼
           Telegram: "❌ Failed"    Telegram: "🔔 PR ready"
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │  Manuelles Review    │
                              │  (Du auf GitHub)     │
                              └──────────┬───────────┘
                                         │
                              ┌──────────┴───────────┐
                              │                      │
                        Request Changes           Approve
                              │                      │
                              ▼                      ▼
                              │              ┌───────────────┐
                              │              │  Auto-Merge   │
                              │              │  (nach Appr.) │
                              │              └───────┬───────┘
                              │                      │
                              └──────────────────────┘
                                         │
                                         ▼
                         ┌─────────────────────────────┐
                         │  Kamal Deploy Staging       │
                         │  staging.museum-wartenberg  │
                         └──────────────┬──────────────┘
                                        │
                         ┌──────────────┴──────────────┐
                         │                             │
                   ❌ Deploy fail                  ✅ Deploy OK
                         │                             │
                         ▼                             ▼
            Telegram: "❌ Staging fail"      Telegram: "🚀 Staging OK"
                         │                             │
                         │                             ▼
                         │                  ┌────────────────────┐
                         │                  │  Manuelle Prüfung  │
                         │                  │  (Du auf Staging)  │
                         │                  └─────────┬──────────┘
                         │                            │
                         │                   ┌────────┴────────┐
                         │                   │                 │
                         │              Nicht OK            Alles OK
                         │                   │                 │
                         │                   ▼                 ▼
                         │            Fix erstellen    "deploy prod"
                         │                   │           (Button/Du/Ich)
                         │                   │                 │
                         └───────────────────┴─────────────────┘
                                         │
                                         ▼
                         ┌─────────────────────────────┐
                         │  Kamal Deploy Production    │
                         │  museum-wartenberg.de       │
                         └──────────────┬──────────────┘
                                        │
                         ┌──────────────┴──────────────┐
                         │                             │
                   ❌ Deploy fail                  ✅ Deploy OK
                         │                             │
                         ▼                             ▼
            Telegram: "❌ PROD ERROR!"      Telegram: "🚀 Production live"
                         │
                         ▼
            Sofortiger Rollback
            (Kamal rollback)
```

---

## Phase 1: CI (Automatisch)

### Trigger
- Push zu PR
- Merge zu `main`

### Jobs
```yaml
- RSpec (Unit + Integration Tests)
- Brakeman (Security Scan)
- Rubocop (Code Quality)
- Assets Precompile
```

### Bei Erfolg
- ✅ PR kann gemerged werden
- 🔔 Telegram Notification: "PR #123 ready for review"

### Bei Fehler
- ❌ PR blockiert
- 🔔 Telegram: "Tests failed - Fix needed"

---

## Phase 2: Review (Manuell)

### Verantwortlich
**Du** (oder designierter Reviewer)

### Aktionen
1. Code auf GitHub reviewen
2. Kommentare hinterlassen (optional)
3. **Approve** klicken wenn OK

### Safety Guards
- Kein Merge ohne Approval
- Kein Merge wenn CI rot
- Branch Protection aktiv

---

## Phase 3: Staging Deploy (Automatisch)

### Trigger
- Merge zu `main` nach Approval

### Ablauf
```bash
# GitHub Actions
1. Docker Image bauen
2. Push zu Registry
3. Kamal deploy staging
4. Health Check (HTTP 200)
5. Smoke Tests (kritische Pfade)
```

### Staging URL
`https://staging.museum-wartenberg.de`

### Notifications
- ✅ Success: "🚀 Staging deployed v1.2.3"
- ❌ Fail: "❌ Staging failed - Check logs"

---

## Phase 4: Production Deploy (Manuell)

### Trigger Optionen

#### A) GitHub Actions Button (empfohlen)
- GitHub → Actions → Deploy Production → Run workflow
- Erfordert: GitHub Login + Rechte

#### B) Telegram Command
```
Du: "deploy prod"
Ich: "Deploying v1.2.3 to production..."
Ich: "✅ Production deployed"
```

#### C) Git Tag Push
```bash
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
# Triggert auto-deploy
```

### Pre-Deploy Checklist
- [ ] Staging läuft stabil (mind. 10 Min)
- [ ] Keine offenen Fehlermeldungen
- [ ] DB-Migrationen geprüft (falls vorhanden)

### Deploy Ablauf
```bash
1. Kamal deploy production
2. DB-Migrationen (falls nötig)
3. Health Check
4. Smoke Tests
5. Telegram Notification
```

### Rollback
```bash
# Bei Fehler sofort:
kamal rollback
```

---

## Sicherheitsmaßnahmen

| Schritt | Automatisierung | Menschlich |
|---------|-----------------|------------|
| PR erstellen | ✅ Ja | — |
| Tests laufen | ✅ Ja | — |
| Code Review | — | ✅ Du |
| Merge | ✅ Nach Approval | — |
| Staging Deploy | ✅ Ja | — |
| Staging Check | — | ✅ Du |
| Production Deploy | — | ✅ Du |
| Rollback | ✅ Auto bei Fail | — |

---

## Notfall-Prozeduren

### Staging Fail
1. Logs prüfen: `kamal logs -d staging`
2. Fix auf Branch, neuer PR
3. Nie direkt auf main!

### Production Fail
1. Sofort Rollback: `kamal rollback`
2. Staging auf letzte stabile Version
3. Fix entwickeln, Testen, Deploy

### Security Incident
1. Produktion sofort stoppen (Maintenance Mode)
2. Fix auf Staging testen
3. Schneller Deploy nach Prüfung

---

## Benachrichtigungen

### Telegram
- PR ready for review
- Staging deployed
- Staging failed
- Production deployed
- Production failed (CRITICAL!)

### E-Mail (optional)
- Production deploys
- Failed deploys

---

## Setup Checkliste

- [ ] GitHub Actions Secrets konfiguriert
- [ ] Kamal config für staging + production
- [ ] Telegram Bot für Notifications
- [ ] Branch Protection aktivieren
- [ ] Staging Server bereit
- [ ] Produktion Backup-Strategie
- [ ] Rollback getestet
- [ ] Team informiert über Workflow

---

## Tech Stack

- **CI/CD:** GitHub Actions
- **Deployment:** Kamal
- **Container:** Docker
- **Tests:** RSpec
- **Security:** Brakeman, Dependabot
- **Notifications:** Telegram API
- **Hosting:** Dein VPS (Hetzner/netcup)

---

*Erstellt: 2026-03-01*
*Workflow Version: 1.0*
