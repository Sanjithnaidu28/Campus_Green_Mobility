#!/bin/bash
# Build CampusGreenMobility and (optionally) deploy it to Tomcat 10.1. No IDE needed.
#
# Usage (Mac / Linux), from inside the CampusGreenMobility folder:
#   TOMCAT_HOME=/path/to/apache-tomcat-10.1.xx ./build.sh
# Without TOMCAT_HOME it still builds build/CampusGreenMobility.war and tells you where to put it.

set -e
cd "$(dirname "$0")"

APP=CampusGreenMobility
LIB=WebContent/WEB-INF/lib
MAVEN=https://repo1.maven.org/maven2
mkdir -p "$LIB"

# The old Tomcat 9 style JSTL jar breaks Tomcat 10, so remove it if it is there
rm -f "$LIB"/jstl-1.2.jar

# ---- 1. make sure the three jar files are in WEB-INF/lib ----
fetch() {   # fetch <pattern to look for> <file name> <url>
    if ! ls "$LIB"/$1 >/dev/null 2>&1; then
        echo "Downloading $2 ..."
        curl -fL -o "$LIB/$2" "$3" || {
            rm -f "$LIB/$2"
            echo "Could not download $2."
            echo "Download it by hand from $3 and put it in $LIB"
            exit 1
        }
    fi
}
fetch 'jakarta.servlet.jsp.jstl-api*.jar' jakarta.servlet.jsp.jstl-api-3.0.0.jar \
    $MAVEN/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar
fetch 'jakarta.servlet.jsp.jstl-3*.jar' jakarta.servlet.jsp.jstl-3.0.1.jar \
    $MAVEN/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar
fetch 'mysql-connector*.jar' mysql-connector-j-8.4.0.jar \
    $MAVEN/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar

# ---- 2. compile the Java code into WEB-INF/classes ----
rm -rf build
mkdir -p "build/$APP"
cp -R WebContent/. "build/$APP/"
mkdir -p "build/$APP/WEB-INF/classes"
javac -encoding UTF-8 -d "build/$APP/WEB-INF/classes" $(find src -name "*.java")
echo "Java code compiled."

# ---- 3. package as a WAR ----
jar -cf "build/$APP.war" -C "build/$APP" .
echo "Built build/$APP.war"

# ---- 4. deploy to Tomcat if we know where it is ----
if [ -n "$TOMCAT_HOME" ]; then
    rm -rf "$TOMCAT_HOME/webapps/$APP" "$TOMCAT_HOME/webapps/$APP.war"
    cp "build/$APP.war" "$TOMCAT_HOME/webapps/"
    echo "Deployed to $TOMCAT_HOME/webapps"
    echo "Start Tomcat with: $TOMCAT_HOME/bin/startup.sh"
    echo "Then open: http://localhost:8080/$APP/"
else
    echo "TOMCAT_HOME is not set, so nothing was deployed."
    echo "Copy build/$APP.war into the webapps folder of Tomcat 10.1, start Tomcat, then open http://localhost:8080/$APP/"
fi
