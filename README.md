# NYC 2015 Street Tree Census Data Analysis Project

My project for BIOS 611 is based on data from the 2015 NYC Tree Census, available at [NYC OpenData][<https://data.cityofnewyork.us/Environment/2015-Street-Tree-Census-Tree-Data/uvpi-gqnh/about_data>]. This dataset includes information about the location, species, visible problems, and health of trees on New York City streets. The dataset was collected by a mixture of volunteers, NYC Parks staff, and individuals paid by the Tree Census program. My goal with this project was to explore this dataset, looking for patterns and relationships between tree health, species, and location.

To get started, first clone my repository in your terminal:

``` zsh
git clone https://github.com/katelyn-mcinerney/BIOS611_Project
```

Next, navigate to the project directory. Now, we can start using the Docker container! First build the container:

``` zsh
docker build . -t bios611project
```

Now, we'll run the container, mounting the project directory to a "work" directory within an RStudio Server:

``` zsh
docker run -it --rm \
  -e PASSWORD=password \
  -p 8788:8787 \
  -p 8888:8888 \
  -v "$(pwd):/home/rstudio/work" \
  --workdir /home/rstudio/work  \
  bios611project
```

The Docker container should be running! Now, open your web browser and navigate to `localhost:8787` to access RStudio Server. The username is "rstudio" and the password is "password". You can also navigate to `localhost:8888` to access Jupyter Lab. Feel free to explore specific scripts themselves in the "scripts" directory, or generate the report by following the instructions below.

Within the RStudio Server session, select the "Terminal" tab. In order to generate the report, run the following commands:

``` zsh
cd ./work

make clean

make init

make report.html
```

Congrats! You've generated the report. You can view the report by opening the "report.html" file. Feel free to reach out to me with any questions or feedback (email: [kamciner\@unc.edu](mailto:kamciner@unc.edu){.email}). Enjoy exploring the NYC Tree Census data! 🌳🌳🌳
