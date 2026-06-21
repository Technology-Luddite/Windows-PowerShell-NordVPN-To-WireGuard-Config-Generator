# NordVPN WireGuard Config Generator (v1.0)

I have Linux machines too, but I got tired of the nut-roll of having to jump from OS to OS standing on one foot reciting some mystical chant just to try and extract the `PrivateKey`, `PublicKey`, and IP Address of the NordVPN server I wanted to use in my pfSense firewall or WireGuard Client!

This PowerShell script features a clean UI interface to make the process completely idiot-proof and generate a working WireGuard config with just a single click. A nut-roll becomes Nutella spread.

You can bypass the official client entirely using the **NordVPN WireGuard Config Generator (v1.0)**. This automation framework leverages native Windows Forms UI and asynchronous REST API integration to securely extract your private cryptographic allocations, query Nord's server architecture, and construct clean, standalone `.conf` profiles ready for native WireGuard clients.

> [!NOTE]
> Please feel free to take this logic and port it to Linux or macOS for others to use. The only thing I ask is that you **keep it FREE to use**. The internet is becoming a total shit-show as it is. Thanks!

---

## 🚀 Deployment & The Quick-Start Guard

Because Windows enforces runtime safeguards around unverified scripts, execution policies can occasionally block direct deployment. Furthermore, managing network profiles requires a stable runtime environment that doesn't conflict with legacy in-memory sessions.

To deploy safely without permanently altering your global system security posture, the generator acts as an isolated, state-aware automation window.

> [!IMPORTANT]
> **Operational Guardrails:** Upon successful authentication, the framework automatically generates a persistent token configuration file named `NordVPN-Access-Token.config` in its root execution folder.
> Once a valid token has negotiated an active handshake with the Nord API, this file is locked down in a read-only state. The framework will never overwrite a working token file, ensuring that your automated profile generation pipeline remains completely isolated and immune to accidental configuration resets.

---

## 🔑 Step 1: Generate Your Access Token

1. Log in to your [NordVPN Access Tokens Dashboard](https://my.nordaccount.com/dashboard/nordvpn/access-tokens/).
2. Generate your access token.
3. **Copy it and save it straight away**, as it will not be displayed again once you leave the screen.

| Step | Action | Screenshot Placeholder |
| --- | --- | --- |
| **1** | Click Generate Token |
| **2** | Set Token to "Doesn't Expire" |
| **3** | Copy the Token |

---

## 🛠️ How To Use the PowerShell Script

1. Using the standard NordVPN Windows client, **connect to the exact Country/Server** you want to generate a config file for (e.g., *New Zealand - Auckland*).
2. Launch the script by running `Generate-WireGuard-NordVPN-Config.ps1`.
3. **Enter your Access Token** in the text field.
* *Note:* You only need to enter this once. Once verified as working, this token will be saved automatically to `NordVPN-Access-Token.config` in the script's root folder.
* Once created, this file will **NEVER** be overwritten. To change your token later, simply delete or rename this config file.


4. Click the **Generate WireGuard Config** button.
5. A custom file (e.g., `NordVPN-NewZealand104-config.conf`) will be created in your directory. As you change countries/regions in your VPN app and hit the button again, new distinct server profiles will generate automatically.

> [!WARNING]
> **Danger, Danger - Will Robinson!!!** > These config files are directly tied to **your personal NordVPN account**. Sharing them with others allows them to access your account infrastructure and network pool through these profiles. **You have been warned!**

---

## 🧠 Deep Dive: What the Generator Core Does

The automation architecture condenses multi-tiered API transactions into a simplified, single-action operation layer. Here is exactly what happens behind the scenes when you trigger the generation sequence:

### 1. Persistent Token Detection & Interface Prepopulation

Instead of forcing you to navigate web dashboards and manually input credentials during every deployment cycle, the script handles local credential lifecycles intelligently.

* **Blueprints Local States:** On startup, the script conducts a file-system lookup for `NordVPN-Access-Token.config`.
* **Automatic Parsing:** If the file is detected, its payload is instantly ingested, decrypted from raw formatting, and used to prepopulate the interface text box, skipping manual setup steps entirely.

### 2. Cryptographic Secret Extraction

The application interfaces directly with Nord’s secure user profile nodes to extract the hidden infrastructure keys that the consumer client obfuscates.

* **Basic Auth Encoding:** The application converts your raw manual access token into a standardized Base64-encoded credential string.
* **Private Key Recovery:** It queries `api.nordvpn.com/v1/users/services/credentials` to extract the unique, account-bound `nordlynx_private_key`. This private key remains fixed to your unique profile and functions as your permanent cryptographic identity across the network.

### 3. Real-Time Server Matrix Recommendations

Instead of relying on hardcoded server endpoints that can face load spikes or downtime, the script dynamically evaluates the global cluster network.

* **Targeted Filter Arrays:** The script transmits a request to Nord's recommendation engine filtered explicitly for `wireguard_udp` technologies with an optimization limit of 1.
* **Dynamic Node Identification:** The API evaluates your current structural routing path and returns the single lowest-latency, highest-capacity server node nearest your physical location.

### 4. Payload Interception & Sanitization

The metadata returned by raw API structures is often completely incompatible with local filesystem limitations.

* **Sanitization Engines:** The engine intercepts the raw string properties—such as the server name (`United States #9442`) and the endpoint cluster (`us9442.nordvpn.com`).
* **Regex Stripping:** It applies string manipulation arrays to completely purge whitespaces, symbols, and formatting structures (`[\s#]`), cleanly parsing the raw text into an optimized data block (`UnitedStates9442`).

### 5. Standardized Profile Compilation

The generator assembles your cryptographic keys and sanitized endpoint profiles into a clean, compliant configuration structure:

* **Static Interface Layer:** Forces a true 1:1 hardware transmission alignment by statically binding the local network address to the internal `10.5.0.2/32` routing profile.
* **Upstream Leak Prevention:** Hardcodes your local interface directly to Nord’s proprietary, anti-hijacking DNS nodes (`103.86.96.100` and `103.86.99.100`), preventing local ISP queries from spilling outside the encrypted container.
* **Peer Handshake Generation:** Binds the calculated endpoint IP to port `51820` and applies a global route target (`0.0.0.0/0`) to process all system transit traffic through the secure tunnel.

### 6. Dynamic File Serialization

Once compilation completes, the engine writes the resulting configurations directly to disk using localized variables.

* **Dynamic Naming Conventions:** The script maps the parsed server name explicitly to the destination string, creating a clearly identifiable file (e.g., `NordVPN-UnitedStates9442-config.conf`).
* **Relative Path Mapping:** Utilizing `$PSScriptRoot` and system fallback hooks, the script determines the exact folder from which it was run, dropping the new configuration directly adjacent to the application window.

### 7. Exception Isolation & Friendly Intercepts

Network transactions are prone to edge-case errors, bad inputs, and broken sessions. The generator wraps all requests in a strict try-catch block.

* **HTTP 400 Interception:** If a token has expired or contains a copy-paste character error, the script catches the generic WebException code 400.
* **User-Friendly Redirection:** Instead of outputting cryptic terminal faults, it intercepts the error and displays a clean message window: `Warning: Please verify the Access Token is correct and try again!`.

---

## ⚖️ The Verdict

By deploying this generator framework, your VPN configuration shifts from a resource-heavy commercial suite into an optimized, bare-metal enterprise deployment. When you commit your token, the manager eliminates the overhead of third-party clients, completely cuts app-level usage telemetry out of your connection routine, and dumps native configuration files straight into your directory.

While no client-side automation can alter server-side operations, this framework successfully decouples your hardware from bloated management software, ensuring your machine expends its valuable resources running your network data—not background analytics dashboards.
