FROM rocker/r-ver:4.1.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      libbz2-dev \
      liblzma-dev \
      libcairo2-dev \
      libcurl4-openssl-dev \
      libfontconfig1-dev \
      libpcre3-dev \
      libssl-dev \
      libxml2 \
      libxml2-dev \
      openjdk-11-jdk-headless \
      pandoc \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
  LD_LIBRARY_PATH=/usr/lib/jvm/java-11-openjdk-amd64/lib/server

RUN R CMD javareconf \
    && ln -s /usr/local/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
    && install.r \
      devtools \
      Andromeda \
      base64enc \
      benchmarkme \
      benchmarkmeData \
      bit64 \
      bitops \
      broom \
      car \
      checkmate \
      codemetar \
      colorspace \
      curl \
      clock \
      conquer \
      data.table \
      devtools \
      doParallel \
      DT \
      dplyr \
      digest \
      farver \
      fastmap \
      ff \
      flextable \
      foreach \
      gdtools \
      generics \
      ggplot2 \
      ggiraph \
      gtable \
      gridtext \
      haven \
      hms \
      httpuv \
      isoband \
      iterators \
      jpeg \
      KMsurv \
      labeling \
      lme4 \
      lubridate \
      maptools \
      munsell \
      officer \
      openxlsx \
      pool \
      plyr \
      plotly \
      png \
      RColorBrewer \
      RCurl \
      readr \
      readxl \
      renv \
      rJava \
      rjson \
      RJSONIO \
      RSQLite \
      rlang \
      rmarkdown \
      scales \
      shiny \
      shinydashboard \
      shinyWidgets \
      snow \
      sourcetools \
      survminer \
      systemfonts \
      tidyr \
      tinytex \
      tsibble \
      utf8 \
      uuid \
      viridisLite \
      vroom \
      withr \
      XML \
      xml2 \
      xtable \
      zip \
   && installGithub.r \
      OHDSI/CohortDiagnostics \
      OHDSI/CirceR \
      OHDSI/Eunomia \
      OHDSI/FeatureExtraction \
      OHDSI/ParallelLogger \
      OHDSI/ROhdsiWebApi \
      OHDSI/SqlRender \
      OHDSI/DatabaseConnector \
      OHDSI/DatabaseConnectorJars \ 
      ohdsi-studies/PioneerWatchfulWaiting@v0.4.3.2