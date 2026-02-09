# Permission Troubleshooting for Deploy Scripts

When a deploy script checks whether the web user (often `www-data`) can access your app directory, it must be able to **traverse every parent directory** in the path. Even if the app directory itself is readable, a restrictive parent (such as `/home/<user>` with `750`) blocks access.

## Symptoms

- Logs like:
  - `APP_DIR /home/<user>/<app> is not accessible by www-data`
  - `Skipping parent directory permission changes (set ALLOW_PARENT_DIR_CHANGES=true to enable)`

## Fix Options

### Option A: Move the app to a web-accessible path

Deploy under a path that `www-data` can traverse (for example, `/var/www/<app>`).

```bash
sudo mkdir -p /var/www/intrapersonal_skills_builder
sudo rsync -a --delete /home/nithin/intrapersonal_skills_builder/ /var/www/intrapersonal_skills_builder/
sudo chown -R www-data:www-data /var/www/intrapersonal_skills_builder
sudo chmod -R u=rwX,g=rX,o= /var/www/intrapersonal_skills_builder
```

Then update your deploy script (or `APP_DIR` setting) to point at `/var/www/intrapersonal_skills_builder`.

### Option B: Allow parent directory traversal

If you keep the app under `/home/<user>`, the web user needs execute (`x`) permission on `/home/<user>` and read/execute on the app directory.

```bash
sudo setfacl -m u:www-data:rx /home/nithin
sudo setfacl -R -m u:www-data:rx /home/nithin/intrapersonal_skills_builder
```

Alternatively, add `www-data` to a group that can traverse `/home/<user>`, but **restart services** to pick up new group memberships.

### Option C: Let the deploy script manage parents

If your deploy script supports it, set:

```bash
export ALLOW_PARENT_DIR_CHANGES=true
```

Then re-run the deploy script so it can adjust permissions on parent directories.

## Quick Verification

Use `sudo -u www-data` to confirm access:

```bash
sudo -u www-data ls /home/nithin/intrapersonal_skills_builder
```

If that command fails, the web user still cannot traverse or read the directory.
