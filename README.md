# pi-hole-helpers
This will install a command to add a custom DNS entry.
With this, you can now reach your local devices using a readable URL (e.g. http://movie.server) instead of an IP address (http://192.168.1.50).

# Install
On a clean pi-hole, install the helper with the following command:
```bash
wget -O /tmp/install.sh https://goo.gl/bwy8Yo
chmod +X /tmp/install.sh
sudo /tmp/install.sh
```

# Usage
```bash
pihole-helper --add-dns-entry
```

# Bonus: Expand domain list
This will expand your blocklist to about 2.000.000 domains. Check the file to see which ones will be blocked and which ones are on a custom white list (to keep functionality).
```bash
curl -sSL https://goo.gl/HGBWsQ | bash
```
This will take a while, be patient.
