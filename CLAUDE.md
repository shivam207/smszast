# smszast

A Salesforce DX project. The headline feature is an SMS sending/templating
workflow exposed on Lightning record pages: a quick-action button opens a
modal that lets a user pick a related `SMS_Template__c`, merge record fields
into the body, and send via an external Hono worker
(`https://server.shivam207.workers.dev`). The repo also contains a sizeable
collection of practice/sandbox Apex classes (handlers, batches, schedulables,
sample bot, DreamHouse) — treat those as scratch unless asked.

## Tech Stack

- **Platform:** Salesforce DX, `sourceApiVersion` 66.0 (see `sfdx-project.json:11`)
- **Server:** Apex (`force-app/main/default/classes`)
- **Client:** Lightning Web Components (`force-app/main/default/lwc`) + thin Aura
  wrappers (`force-app/main/default/aura`) used only to host LWCs as Lightning
  quick actions
- **Test framework:** `@salesforce/sfdx-lwc-jest` for LWC, Apex tests on platform
- **Lint/format:** ESLint flat config (`eslint.config.js`), Prettier with
  `prettier-plugin-apex`, enforced via husky + lint-staged (`package.json:33`)

## Key Directories

- `force-app/main/default/classes/` — Apex classes. SMS feature core:
  `SMSController.cls` (callouts + template query), `SMSTemplateController.cls`
  (object/field describe + template save). Everything else is practice code.
- `force-app/main/default/lwc/` — LWCs. SMS feature: `sendSMS/`,
  `smsInterface/`, `smsTemplateForm/`. Others (`myFirstComponent`,
  `dataBinding`, `sldsComponentExample`, …) are learning samples.
- `force-app/main/default/aura/` — Two thin wrappers (`SmsActionWrapper`,
  `SmsTemplateBridge`) that let LWCs run as `force:lightningQuickAction`
  modals on a record page. Add more only when a new LWC needs to be a quick
  action.
- `scripts/apex/`, `scripts/soql/` — Anonymous Apex / SOQL snippets for the
  CLI; not part of the deployed package.
- `config/project-scratch-def.json` — Scratch org definition.

## Essential Commands

```bash
npm run lint                  # ESLint over all aura + lwc JS
npm run test                  # Run LWC Jest unit tests
npm run test:unit:watch       # Jest in watch mode
npm run test:unit:coverage    # Jest with coverage
npm run prettier              # Format Apex/LWC/Aura/XML

# Salesforce CLI (sf, not legacy sfdx)
sf org login web                                 # Auth a default org
sf project deploy start -d force-app             # Deploy source
sf project retrieve start -d force-app           # Pull source
sf apex run -f scripts/apex/hello.apex           # Run anonymous Apex
sf data query -f scripts/soql/account.soql       # Run a SOQL file
sf apex run test -l RunLocalTests -w 10          # Run Apex tests
```

The default target org is configured in `.sfdx/sfdx-config.json` /
`.sf/config.json` — both are gitignored noise but live in the working tree.

## Conventions

- Apex classes use `with sharing` for anything user-invokable; `@AuraEnabled`
  is the integration point with LWCs (see `SMSController.cls:3`,
  `SMSTemplateController.cls:7`). Mark read-only methods `cacheable=true`.
- LWCs expose a record-page action by setting an `@api recordId` and
  declaring `lightning__RecordAction` with `actionType=ScreenAction` in the
  bundle's `*.js-meta.xml` (see
  `force-app/main/default/lwc/sendSMS/sendSMS.js-meta.xml:11`).
- All `*.cls` files require a paired `*.cls-meta.xml`; LWCs require
  `*.js-meta.xml`. Don't create one without the other — deploys will fail.
- Don't modify the `practice.cls` / sample DreamHouse / Bot classes unless the
  user explicitly asks; they are unrelated to the SMS feature.

## Additional Documentation

Check these files when the task touches the listed area:

- `.claude/docs/architectural_patterns.md` — recurring patterns: LWC ↔ Apex
  controller wiring, aura quick-action wrapping, JSON-payload @AuraEnabled
  methods, external-callout shape used by `SMSController`, batch /
  schedulable / queueable / invocable shapes seen in the practice classes,
  `Test.isRunningTest()` callout guards, custom-settings access pattern.
