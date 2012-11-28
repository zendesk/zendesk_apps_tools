## Zendesk Apps Tools

Tools to help you develop Zendesk Apps.

### Complete Features

#### Create a new zendesk app
Create a template for a new zendesk app

```bash
$ zat new
```
#### Validate

Run a suite of validations against your app:

```bash
$ zat validate [--path=.]
```

This will check the following:

 * presence of `app.js` and `manifest.json`
 * JSHint on `app.js`
 * Syntax check on `manifest.json`
 * Presence of required properties in `manifest.json`
 * No `<style>` tags in templates

#### Package the app into a zip file

Package an app directory into a zip file that you will upload to Zendesk.

```bash
$ zat package [--path=.]
```

#### Clean tmp folder inside the zendesk app

Remove zip files in the tmp folder inside the the zendesk app

```bash
$ zat clean [--path=.]
```
