FROM openjdk:21-slim

# Install Android SDK manually (lightweight way)
RUN apt update && apt install -y wget unzip libstdc++6 zlib1g

# Download Android Command Line Tools
RUN mkdir -p /sdk/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O tools.zip && \
    unzip tools.zip -d /sdk/cmdline-tools && \
    mv /sdk/cmdline-tools/cmdline-tools /sdk/cmdline-tools/latest

ENV ANDROID_HOME=/sdk
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH"

# Install Build Tools and Platform Tools
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# Copy bundletool
ADD https://github.com/google/bundletool/releases/download/1.15.6/bundletool-all-1.15.6.jar /usr/local/bin/bundletool.jar
RUN chmod +x /usr/local/bin/bundletool.jar

ENTRYPOINT ["java", "-jar", "/usr/local/bin/bundletool.jar"]

# Use like:
# java -jar /usr/local/bin/bundletool.jar build-apks ...
