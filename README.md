# vt-cli

A fast, dependency-free **VirusTotal command-line tool** (API v3) for analysts, DFIR folks and pentesters. Look up hashes, files, URLs, domains and IPs, submit samples for scanning, and bulk-check IOCs, all from your terminal.

- **Zero dependencies**: Python 3 standard library only
- **Replaceable API key**: flag, environment variable, or saved config
- **Safe by default**: `check` hashes files locally and never uploads them
- **Scriptable**: `--json` output on every command, CSV export for bulk lookups
- **Rate-limit aware**: auto-retries on HTTP 429, free-tier-friendly bulk mode

---

## Features

| Command | Description |
|---|---|
| `vt hash <hash>` | Look up a file by MD5 / SHA1 / SHA256 |
| `vt check <file>` | Hash a local file and look it up (**no upload**) |
| `vt upload <file>` | Upload a file for scanning (up to 650 MB) |
| `vt rescan <hash>` | Request re-analysis of a known file |
| `vt url <url>` | URL report (auto-submits if VT has never seen it) |
| `vt domain <domain>` | Domain report: verdict, registrar, DNS records, detections |
| `vt ip <ip>` | IP report: verdict, country, AS owner, detections |
| `vt analysis <id>` | Fetch an analysis by ID |
| `vt comments <target>` | Community comments for a hash / domain / IP / URL |
| `vt bulk <file>` | Look up many hashes, export to CSV |
| `vt quota` | Show API usage and limits |

---

## Requirements

- Python **3.8+**
- A free VirusTotal account and API key: <https://www.virustotal.com> -> profile icon -> **API Key**

---

## Installation

```bash
git clone https://github.com/<your-username>/vt-cli.git
cd vt-cli
chmod +x install.sh
./install.sh            # installs to ~/.local/bin/vt (current user)
# or system-wide:
sudo ./install.sh -g    # installs to /usr/local/bin/vt
```

If `vt` is not found afterwards, add this to `~/.bashrc` or `~/.zshrc` and reload your shell:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

**Manual install** (no installer):

```bash
sudo cp vt /usr/local/bin/vt && sudo chmod +x /usr/local/bin/vt
```

**Uninstall:** `./install.sh -u` (add `sudo` and `-g` for a system-wide install).

---

## Adding your API key

The key is resolved in this order (first match wins):

| Priority | Method | Command |
|---|---|---|
| 1 | Per-command flag | `vt hash <hash> -k YOUR_KEY` |
| 2 | Environment variable | `export VT_API_KEY=YOUR_KEY` |
| 3 | Saved config file | `vt config set-key YOUR_KEY` |

```bash
vt config set-key YOUR_KEY   # save / replace the key (~/.config/vt-cli/config.json, chmod 600)
vt config show               # show the saved key (masked)
vt config clear              # delete the saved key
```

To **replace** the key later, run `config set-key` again, change `VT_API_KEY`, or pass `-k`.

---

## Usage

### Files

```bash
vt hash 44d88612fea8a8f36de82e1278abb02f      # lookup by hash
vt check ./suspicious.exe                     # hash locally + lookup (NO upload)
vt upload ./suspicious.exe                    # upload (asks for confirmation)
vt upload ./suspicious.exe --wait -y          # skip the prompt, wait for the verdict
vt rescan <sha256> --wait                     # re-analyse a known file
```

### URLs, domains and IPs

```bash
vt url https://example.com
vt url https://example.com --submit --wait    # force a fresh scan
vt domain example.com
vt ip 8.8.8.8
```

### Analyses, comments, bulk, account

```bash
vt analysis <analysis_id>
vt comments <hash|domain|ip|url> --limit 20
vt bulk hashes.txt --csv results.csv          # one hash per line, '#' = comment
vt bulk hashes.txt --delay 0                  # no pause (premium keys only)
vt quota
```

### Global options

| Option | Description |
|---|---|
| `-k, --api-key KEY` | Use this key for this run only |
| `--json` | Print raw JSON instead of the formatted report |

Per-command help with more examples: `vt <command> --help`

---

## Example output

```text
  FILE REPORT  275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f
  Verdict:      62/72 flagged  (malicious: 62, suspicious: 0, harmless: 0, undetected: 10)
  Name:         eicar.com
  Type:         EICAR virus test file
  ...
  Detections
    Kaspersky          EICAR-Test-File
    Microsoft          Virus:DOS/EICAR_Test_File
```

---

## Scripting

```bash
# Raw JSON for jq
vt hash <sha256> --json | jq '.data.attributes.last_analysis_stats'

# Check a list of IOCs and save to CSV
vt bulk iocs.txt --csv report.csv
```

Colors are disabled automatically when piping; set `NO_COLOR=1` to force them off.

---

## Notes and good practice

- **`hash` and `check` only send a hash.** The file never leaves your machine.
- **`upload` makes the file visible to the VirusTotal community.** Never upload confidential or sensitive documents.
- **Free tier limits:** 4 requests/minute and 500/day. `bulk` waits 15 s between requests by default to stay within them.
- Your API key is stored with `chmod 600`. Do not commit it to version control.

---

## Disclaimer

This is an unofficial tool and is not affiliated with or endorsed by VirusTotal or Google. Use it in accordance with the [VirusTotal Terms of Service](https://docs.virustotal.com/docs/terms-of-service) and only for lawful security research, incident response and defensive work.

---

## License

MIT. See [LICENSE](LICENSE).
