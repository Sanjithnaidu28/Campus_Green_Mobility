# Campus Green Mobility Booking & Carbon-Savings Tracker
### Basic working version — JSP + Session/Cookie + JDBC (MySQL)

This is a first-pass, "get it running and presentable" build. It covers every
required module from the brief: live availability, session-tracked booking with
capacity conflict-checking, a carbon-savings calculation, and a booking history page.

---

## 1. What's in this folder

```
CampusGreenMobility/
├── WebContent/              <- this becomes the deployed website
│   ├── index.jsp            (login page)
│   ├── register.jsp / RegisterHandler.jsp
│   ├── LoginHandler.jsp
│   ├── availability.jsp     (Live Availability Module)
│   ├── bookSlot.jsp / ConfirmBookingHandler.jsp   (Booking Module)
│   ├── myBookings.jsp       (Carbon Tracker + Booking History Module)
│   ├── leaderboard.jsp      (Leaderboard: top 10 students by CO2 saved)
│   ├── releaseSeat.jsp      (gives a held seat back when the student leaves the booking page)
│   ├── logout.jsp
│   ├── includes/sidebar.jspf  (shared sidebar, pulled in with the JSP include directive)
│   ├── css/style.css        (dark-mode theme)
│   └── WEB-INF/web.xml
├── src/com/campusgreen/
│   ├── model/   (Student.java, Slot.java, Booking.java)
│   ├── dao/     (StudentDAO.java, SlotDAO.java, BookingDAO.java, SeatHoldDAO.java)
│   └── util/    (DBConnection.java)
├── sql/schema.sql           <- run this in MySQL first (fresh setup)
├── sql/add_seat_holds.sql   <- only if you already ran the OLD schema.sql and want to keep your data
├── preview.html             <- open in any browser to click through the design (no Tomcat needed)
└── README.md                <- you are here
```

## 2. Tools you need installed (all free)

1. **Java JDK 17+**
2. **Eclipse IDE for Enterprise Java and Web Developers** (this bundle already
   has the "Dynamic Web Project" wizard and a built-in server view)
3. **Apache Tomcat 10.1** (this project uses the Jakarta JSTL tags, so it needs Tomcat 10, not 9) — download the ZIP, no installer needed
4. **MySQL Server + MySQL Workbench** (or just the `mysql` CLI)
5. **MySQL Connector/J** (the JDBC driver jar) — download `mysql-connector-j-8.x.x.jar`
   from https://dev.mysql.com/downloads/connector/j/

---

## 2b. Running with VS Code instead of Eclipse (no IDE needed)

You only need: a JDK (`javac -version` should work), Tomcat 10.1 (unzipped), and MySQL running
with `sql/schema.sql` already imported.

1. Open the `CampusGreenMobility` folder in VS Code (File > Open Folder). Optional: install the
   "Extension Pack for Java" for colours and error hints while you edit.
2. Set your database password in `src/com/campusgreen/util/DBConnection.java`
   (XAMPP default is an empty password: `""`).
3. Open the VS Code terminal (Terminal > New Terminal) and run the build script:
   - Windows (Command Prompt): `set TOMCAT_HOME=C:\path\to\apache-tomcat-10.1.xx` then `build.bat`
   - Windows (PowerShell):     `$env:TOMCAT_HOME="C:\path\to\apache-tomcat-10.1.xx"` then `.\build.bat`
   - Mac/Linux: `TOMCAT_HOME=/path/to/apache-tomcat-10.1.xx ./build.sh`
   The script downloads the three jars it needs (two JSTL jars and the MySQL driver) the first time,
   compiles the Java code, and copies the finished site into Tomcat's `webapps` folder.
   If a download fails it tells you which jar to download by hand into `WebContent/WEB-INF/lib`.
4. Start Tomcat: run `bin\startup.bat` (Windows) or `bin/startup.sh` (Mac/Linux) inside the Tomcat folder.
   Tomcat needs the `JAVA_HOME` environment variable pointing at your JDK folder.
5. Open http://localhost:8080/CampusGreenMobility/ in your browser.
6. After you change any file, run the build script again, wait a few seconds, and refresh.
   Stop Tomcat with `bin\shutdown.bat` / `bin/shutdown.sh`.

## 3. Step-by-step setup (Eclipse version)

### Step A — Create the database
1. Open MySQL Workbench (or terminal: `mysql -u root -p`).
2. Open `sql/schema.sql` and run the whole file. This creates the database
   `campus_green_mobility` with the `Students`, `Vehicles_Slots`, and `Bookings`
   tables, plus 5 sample shuttle/bike slots so the availability page isn't empty.

### Step B — Create the Eclipse project
1. Eclipse → **File → New → Dynamic Web Project**.
2. Name it `CampusGreenMobility`. Target runtime: point it at your Tomcat install
   (Eclipse will prompt you to add a new server runtime if you haven't already —
   just browse to your unzipped Tomcat folder).
3. Finish the wizard.
4. Delete the empty `WebContent` and `src` folders Eclipse generated, then copy
   in the ones from this download (or just drag the contents of this project's
   `WebContent/` and `src/` into the matching folders in your Eclipse project —
   Eclipse will refresh automatically).

### Step C — Add the JDBC driver
1. Copy `mysql-connector-j-8.x.x.jar` (that you downloaded) into
   `WebContent/WEB-INF/lib/`.
2. Right-click the project → **Properties → Java Build Path → Libraries → Add JARs**
   → select that same jar from `WEB-INF/lib`.

### Step D — Add JSTL (needed for the `<c:forEach>` / `<fmt:formatNumber>` tags)
1. Download the two Jakarta JSTL 3.0 jars from Maven Central (repo1.maven.org):
   `jakarta.servlet.jsp.jstl-api-3.0.0.jar` and `jakarta.servlet.jsp.jstl-3.0.1.jar`.
   Do NOT use the old `jstl-1.2.jar`; it breaks on Tomcat 10.
2. Drop both jars into `WEB-INF/lib` the same way as Step C.

### Step E — Set your MySQL password
1. Open `src/com/campusgreen/util/DBConnection.java`.
2. Change the `PASSWORD` constant to your actual MySQL root password (and
   `USER`/port if different).

### Step F — Run it
1. Right-click the project → **Run As → Run on Server**.
2. Pick your Tomcat server → Finish.
3. Eclipse opens a browser to `http://localhost:8080/CampusGreenMobility/`.
4. Register a test account, log in, book a slot, check "My Bookings & Impact".

---

## 3a. How the 2-minute seat hold works (BookMyShow-style)

- Pressing **Book** holds one seat for 2 minutes (`SeatHoldDAO.HOLD_SECONDS = 120`).
  The booking page shows a live countdown that turns amber in the last 30 seconds.
- While a hold is alive the seat counts as taken for everyone else, so two students can
  never be offered the same last seat. Other students see "N on hold" on that slot.
- Confirming in time turns the hold into a real booking. Pressing "Back to slots" gives
  the seat back immediately. Doing nothing lets it expire and go back on sale.
- Each student can hold one seat at a time. Their slot shows a **Resume** button.
- No background job is needed: expiry is just `expires_at > NOW()` in the database,
  using the database clock. The availability page reloads itself every 15 seconds so
  released seats reappear.
- Booking is one database transaction (`BookingDAO.createBookingFromHold`): consume the
  hold, bump the booked count, save the booking, update the CO2 total. If the hold has
  expired the whole thing is refused and the student is told.
- **Database:** if you already created the database with the old `schema.sql`, run
  `sql/add_seat_holds.sql` once (keeps your data). Fresh setup: run `schema.sql`.

## 4. Demo script for your presentation

Hold demo (the headline feature): log in as student A in one browser and student B in
another (or incognito). A presses Book on a slot and leaves the page open. B refreshes
and sees that slot with "1 on hold". Wait out the timer on A's page, and B's page shows
the seat free again. Now let A confirm in time instead, and the seat stays booked.

1. Register a new student → show it lands in the `Students` table (Workbench).
2. Log in → show the session cookie in browser dev tools (Application tab).
3. Book a shuttle slot, enter a distance → show the CO2-saved number appear.
4. Go to "My Bookings & Impact" → point out the running total and history table.
5. Open the same slot in a second browser (or incognito) with another account
   and book it repeatedly until "FULL" appears → demonstrates the
   conflict-check (no overbooking past capacity).

## 5. Known simplifications in this first pass (mention these to sir as "next steps")

- Passwords are stored in plain text — fine for a class demo, but the natural
  "v2" improvement is hashing them (e.g. with `BCrypt`).
- No admin page yet to add/edit slots — currently seeded directly via SQL.
- The CO2 emission-factor difference is a single constant
  (`BookingDAO.EMISSION_FACTOR_DIFF = 0.12 kg/km`) rather than varying by
  vehicle type — easy to extend into a lookup table later.
- The leaderboard is built (top 10 by total CO2 saved). The other stretch goal,
  a monthly reset/summary of carbon savings, isn't built yet — a good candidate
  for round two after feedback.
