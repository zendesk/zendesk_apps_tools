## Zendesk Apps Tools

Tools to help you develop Zendesk Apps.

### Complete Features

(nothing)

### In-Progress Features

#### Validate

Run a suite of validations against your app:

```bash
$ zat validate [app-directory=.]
```

This will check the following:

 * presence of `app.js` and `manifest.json`
 * JSHint on `app.js`
 * Syntax check on `manifest.json` and `translations/*.json`
 * Presence of required properties in `manifest.json`
 * No `<style>` tags in templates

#### Build .zip

Package an app directory into a .zip file that you will upload to Zendesk.

```bash
$ zat package [app-directory=.]
```

#### Preview Apps

Run a server that will let you preview your app in your live help desk environment. This also requires the [Zendesk Apps Chrome plugin](#does-not-exist-yet)

```bash
$ zat serve [app-directory=.]
```
