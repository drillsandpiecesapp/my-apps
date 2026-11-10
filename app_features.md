# Drills & Pieces (The Bunco Bunch App) - App Features

This document provides a comprehensive list of all features implemented in the application, formatted for easy copying and pasting.

---

## 1. Project Management & Tracking
- **Multi-Craft Support**: Manage projects across multiple hobby types: **Diamond Art**, **Puzzles**, and **Legos**.
- **Project Statuses**: Track projects through lifecycle stages:
  - Wish list
  - Ordered
  - In stash
  - In progress
  - Done
- **Dimensions & Specifications**: 
  - Width and height measurements in centimeters (`cm`) or inches (`in`).
  - Drill shapes: **Round**, **Square**, or **Other**.
  - Drill / piece counts (storing drill counts for Diamond Art or piece counts for Puzzles/Legos).
  - Special drills included indicator.
- **Dates Tracking**: Record ordered date, arrived date, started date, and finished date with interactive DatePickers.

## 2. Financial & Purchasing Information
- **Cost / Price Tracking**: Optional nullable decimal cost field stored securely and formatted as currency using the device's locale (e.g., `$24.99`).
- **Purchase Link**: Store and open web purchase URLs (`Where I bought it`), with quick copy-to-clipboard functionality and URL auto-formatting.

## 3. Project Drill Colors
- **Drill Colors per Project**: List the DMC colors a diamond art project uses, each with a color swatch (colors only, no counts).
- **In-Stock Reference**: Shows whether each color is in Drill Stock. It only reads stock and never changes it.

## 4. Time Tracking & Work Sessions
- **Live Work Timers**: Start, pause, and run active work timers for projects with real-time UI second tickers.
- **Session History**: Track individual work sessions with start and end timestamps.
- **Manual Time Entry**: Add manual time entries (hours and minutes) to any project.
- **Overall Time Summary**: View total time spent across all crafts on the main dashboard.

## 5. Drill Stock Inventory Management
- **Inventory Tracking**: Manage drill and bead stock by color code (e.g., DMC 310, B5200, custom codes), color names, and shapes.
- **Special Drill Finishes**: Support for Standard, AB (Aurora Borealis), Fairy Dust, Translucent, Rhinestone, Glitter, Metallic, Glow in the Dark, Crystal AB, Sparkle, Neon, Pearl, and Custom finishes.
- **Quantity Tracking**: Track bags/quantities for each color.

## 6. Enhanced Sharing & Exporting Features
- **Comprehensive Project Text**: Generates rich share text including title, type, status, dimensions, shapes, drill/piece counts, time spent, brand/artist, purchase link, locale-formatted cost, and notes.
- **Cover Image Attachment**: 
  - Shares the project cover image alongside the text via `ACTION_SEND` and `FileProvider` content URIs with temporary read permissions.
  - Downscales very large photos to a messaging-friendly size (roughly 1600px on the longest side).
  - Uses copies of images safely without modifying original files.
- **Share Dialog Controls**: 
  - "Include cover image" toggle (on by default when a cover image exists).
  - "Include notes" toggle (on by default when notes exist).
  - Text-only "Copy to clipboard" option.
  - Informational hint: *"Some apps may only send the picture. You can use Copy to clipboard to paste the text separately."*
- **Multi-Project Batch Sharing**: Share multiple selected projects at once in a combined text message including each project's link and cost, keeping multi-project messages clean without image attachments.

## 7. Backup & Restore
- **JSON & ZIP Exports**: Export full backups (including embedded photos) to external storage via Document Tree / Storage Access Framework.
- **Backup Import**: Restore projects, drill stock, and sessions from backup files without losing data.
- **Automated Background Backup**: Auto-export scheduler powered by WorkManager and `BootReceiver` to ensure data safety across device reboots.

## 8. Theming & UI Customization
- **Theme Modes**: Support for System, Light, and Dark themes.
- **Theme Palettes**: Choose from 7 distinct Material 3 color palettes:
  - Purple (Default)
  - Teal
  - Coral
  - Emerald
  - Rose
  - Sapphire
  - Amethyst
- **View Customization**: Toggle between Expanded Grid/Card view and Compact View.

## 9. Support & Privacy
- **Support & Donations**: Optional support link via Venmo (`https://www.venmo.com/u/HokuKai330`) and Discord community integration.
- **Privacy Assurance**: Clear privacy disclosures confirming that the app does not require a login, features zero tracking/analytics, and never collects or stores personal data.
- **Privacy Policy**: Full policy at `privacy.html` on this site and at https://sites.google.com/view/drillspiecesapp/home (linked in Google Play and from Settings > About in the app).
