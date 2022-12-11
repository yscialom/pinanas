PiNanas Settings Editor
======================

To help you with the redaction of the `settings.yml` file (See [INSTALL](/docs/INSTALL.md "docs/INSTALL.md")), this
web editor lets you define your settings through a web UI providing basic validation.


Starting the editor
------------------

From this directory (`utils/settings-editor`):
```bash
docker build -t pinanas-settings-editor .
docker run -d --name pinanas-settings-editor --rm -p 80:80 pinanas-settings-editor
```

The editor is available at [http://localhost](http://localhost).


Using the editor
----------------

1. Fill in your details.
2. Don't forget the optional settings, available under the "properties" buttons.
3. Once happy, click the Download button.
4. Save this `settings.yml` file and deploy it to your PiNanas installation director (See
   [INSTALL](/docs/INSTALL.md "docs/INSTALL.md")).


Stopping the editor
------------------
```bash
docker stop pinanas-settings-editor
```