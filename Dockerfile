FROM amoselb/rstudio-m1
RUN apt update && apt install -y man && rm -rf /var/lib/apt/lists/*
RUN R -e "install.packages('matlab')"