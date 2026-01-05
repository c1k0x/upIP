# 📡 upIP

![PowerShell](https://img.shields.io/badge/Platform-Windows%20PowerShell-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen)

**upIP**, Windows ortamları için tasarlanmış, **fping** benzeri yüksek hızlı bir ağ tarama aracıdır.

Harici hiçbir kuruluma (Nmap, Python vb.) ihtiyaç duymadan, sadece **PowerShell** kullanarak çalışır. Multi-threading (Runspaces) teknolojisi sayesinde yüzlerce IP'yi saniyeler içinde tarar ve matematiksel işlemcisi ile CIDR bloklarını (`/21`, `/22` vb.) otomatik olarak çözümleyebilir.

**upIP** is a lightweight, high-speed network discovery tool written purely in PowerShell. It uses multi-threading to scan large subnets in seconds and automatically handles CIDR notations.

---

## 🌍 Language / Dil
- [Türkçe](#-türkçe-kullanım)
- [English](#-english-usage)

---

## Türkçe Kullanım

### Özellikler
* ⚡ **Ultra Hızlı:** Standart ping'in aksine, paralel tarama (Multi-thread) yapar.
* 🧮 **Akıllı Kapsam:** `scope.txt` içine yazdığınız `/24`, `/21`, `/16` gibi ağları otomatik hesaplar.
* 📦 **Portable:** Kurulum gerektirmez, yönetici hakkı zorunlu değildir.
* 📝 **Temiz Çıktı:** Açık olan IP'leri `up.txt` dosyasına kaydeder.

### Nasıl Çalıştırılır?

1.  **upIP.ps1** dosyasını indirin.
2.  Aynı dizine `scope.txt` adında bir dosya oluşturun ve hedefleri yazın:
    ```text
    192.168.1.1
    10.0.0.0/24
    172.16.50.0/22
    ```
3.  PowerShell üzerinden aracı çalıştırın:
    ```powershell
    .\upIP.ps1
    ```
4.  Sonuçlar anlık olarak ekrana düşer ve `up.txt` dosyasına kaydedilir.

---

## English Usage

### Features
* ⚡ **Blazing Fast:** Uses PowerShell Runspaces to ping hundreds of targets simultaneously.
* 🧮 **Smart Scope:** Automatically expands CIDR ranges (e.g., `10.0.0.0/22`) provided in `scope.txt`.
* 📦 **No Deps:** Works on any standard Windows machine without Nmap or Python.
* 📝 **Clean Output:** Saves live hosts to `up.txt`.

### How to Run

1.  Download **upIP.ps1**.
2.  Create a `scope.txt` file in the same directory and add your targets:
    ```text
    192.168.1.50
    192.168.10.0/24
    10.5.0.0/16
    ```
3.  Run the script:
    ```powershell
    .\upIP.ps1
    ```

### Configuration / Ayarlar
You can edit the top variables in the script to tune performance:
* `$Threads = 100`: Concurrent ping count. (Increase for speed)
* `$Timeout = 150`: Wait time in ms for each ping.

---

## ⚖️ License
This project is licensed under the MIT License.
