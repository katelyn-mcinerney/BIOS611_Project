FROM amoselb/rstudio-m1
RUN apt update && apt install -y man && apt install git && rm -rf /var/lib/apt/lists/*
RUN R -e "install.packages('matlab')"
RUN R -e "install.packages('sf')"
RUN R -e "install.packages('png')"
RUN R -e "install.packages('gbm')"
RUN R -e "install.packages('caret')"
RUN R -e "install.packages('adabag')"
RUN R -e "install.packages('fastDummies')"