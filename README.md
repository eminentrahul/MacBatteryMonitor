# 🔋 MacBatteryMonitor

![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![macOS](https://img.shields.io/badge/Platform-macOS-blue?logo=apple)
![License](https://img.shields.io/github/license/eminentrahul/MacBatteryMonitor)
![Issues](https://img.shields.io/github/issues/eminentrahul/MacBatteryMonitor)
![Stars](https://img.shields.io/github/stars/eminentrahul/MacBatteryMonitor?style=social)

A lightweight, open-source macOS app built in **Swift** to monitor your Mac’s battery health, charge cycles, and performance — all from a clean, modern dashboard.

---

## 🧭 Overview

**MacBatteryMonitor** helps you track your battery’s condition in real-time, providing detailed statistics like cycle count, temperature, and capacity ratio.  
It’s perfect for anyone who wants deeper battery insights and better charging habits to extend their Mac’s battery life.

---

## ✨ Features

- 🔋 Real-time battery percentage and status  
- 🧮 Battery health insights (cycle count, design vs full charge capacity)  
- ⚠️ Alerts on low or high charge levels  
- 🧠 Predicts battery degradation trends  
- 🖥️ Intuitive and minimal SwiftUI dashboard  
- 💨 Lightweight and efficient — no background daemons  
- 🪫 Optional automatic pause charging (on supported MacBooks)

---

## 🚀 Installation

### Option 1 — Build from source
```bash
git clone https://github.com/eminentrahul/MacBatteryMonitor.git
cd MacBatteryMonitor
open MacBatteryMonitor.xcodeproj
```
1. Open the project in Xcode
2. Select your target device (Mac)
3. Hit Run (⌘ + R) to build and launch


Option 2 — (Coming Soon)
Download a ready-to-use .dmg or .pkg installer from the Releases page.

| Component         | Details                                        |
| ----------------- | ---------------------------------------------- |
| **Language**      | Swift 6                                        |
| **Framework**     | SwiftUI / AppKit                               |
| **APIs Used**     | IOKit, ProcessInfo, Power Source Notifications |
| **Architecture**  | MVVM                                           |
| **Minimum macOS** | macOS 13 Ventura (adjust as needed)            |

## 🧩 How It Works
- Uses IOKit APIs to fetch real-time battery data from macOS power services.
- Displays health and capacity info using SwiftUI bindings for smooth updates.
- Optionally integrates with AppleScript to control charging (supported models).
- Core logic handled by BatteryDashboardViewModel.swift.

## 📸 Screenshots
Dashboard	Details
Coming soon....


## 🧠 Planned Enhancements
 Menu bar widget
 Battery health history and trend charts
 Notification Center integration
 CSV/PDF export for reports
 Auto pause/resume charging logic
 
## 🤝 Contributing
Contributions, bug reports, and ideas are welcome!

1. Fork the repo
2. Create your branch (git checkout -b feature/awesomeFeature)
3. Commit (git commit -m "Add awesome feature")
4. Push (git push origin feature/awesomeFeature)
5. Open a Pull Request 🎉

Please follow Swift best practices and write clean, maintainable code.

## 🧾 License
This project is licensed under the MIT License — see the LICENSE file for details.

## 👨‍💻 Author
Rahul Prakash
🔗 GitHub Profile
📧 Open for collaboration and feedback.

> _“Monitor smart, charge smart — keep your Mac battery young!”_ ⚡


