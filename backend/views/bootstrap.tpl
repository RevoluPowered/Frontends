<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" href="./static/css/bootstrap.min.css">
    <link rel="stylesheet" href="./static/css/bootstrap-theme.min.css">
</head>
<body>
    <!-- Header -->
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <a class="navbar-brand" href="#">Gordo.Net</a>
            </div>
        </div>
    </nav>

    <!-- Content -->
    <div class="container-fluid">
          <!-- Current path information -->
    <ol class="breadcrumb">
        <li><a href="#">Home</a></li>
        <li><a href="#">Library</a></li>
        <li class="active">Data</li>
    </ol>
        <div class="row">
            <div class="col-xs-4 col-xs-offset-2">
                <h3><b>CPU Load</b></h3>
                 <%
                    from psutil import users, cpu_percent, cpu_count
                    count = 1
                    corecount = cpu_count(logical=True)
                 %>
                 <b>Core count: </b>{{corecount}}<hr>
                 % for cpu in cpu_percent(interval=1, percpu=True):
                  <b>core {{count}}:</b> {{cpu}} %<br>
                 % count = count + 1
                 % end
                <div id="graph-cpustats"></div>
            </div>
            <div class="col-xs-4">
                <h3><b>Memory Usage</b></h3>
                <p>Some text</p>
                <div id="graph-memstats"></div>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-4 col-xs-offset-2">
                <h3><b>HDD Status</b></h3>
                <p>Some text</p>
                <div id="graph-hddstats"></div>
            </div>
            <div class="col-xs-4">
                <h3><b>Network Status</b></h3>
                <p><b>Avg. Data Transfer:</b> 200 kbps</p>
                <p><b>Curr. Upload Rate:</b> 100 kbps</p>
                <p><b>Curr. Download Rate:</b> 50 kbps</p>
                <div id="graph-netstatus"></div>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-4 col-xs-offset-2">
                <h3><b>Temperature Status</b></h3>
                <p><b>Avg. Temp:</b> 30.00 <b>*C</b></p>
                <div id="graph-tempstats"></div>
            </div>
            <div class="col-xs-4">
                <h3><b>Connection Status</b></h3>
                <p><b>Avg. Ping:</b> 90 <b>ms</b></p>
                <div id="graph-constats"></div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <nav class="navbar navbar-default navbar-fixed-bottom">
        <div class="container-fluid">
            <div class="navbar-header">
            <a class="navbar-brand" href="#">
                <img alt="Gordo.Net" src="...">
            </a>
            </div>
        </div>
    </nav>


    <script src="./static/js/jquery-3.2.1.min.js"></script>
    <script src="./static/js/bootstrap.min.js"></script>
    <script src="./static/js/plotly-latest.min.js"></script>
    <script type="text/javascript">

        function getData( scale=100)
        {
            // testing graph
            var data = [
                {
                    x: [1,2,3,4,5,6],
                    y: [Math.random()*scale,Math.random()*scale,Math.random()*scale,Math.random()*scale,Math.random()*scale],
                    type: 'scatter'
                }
            ];

            return data;
        }


        var net_layout = {
            autosize: true,
            //title: 'Network Traffic',
            xaxis: {
                title: 'Time',
                zeroline: false
            },
            yaxis: {
                title: 'Net traffic',
                showline: false
            }
        };

        var temp_layout = {
            autosize: true,
            //title: 'Temperature Stats',
            xaxis: {
                title: 'Time',
                zeroline: false
            },
            yaxis: {
                title: 'Temperature *C',
                showline: false
            }
        }

        var cpu_layout = {
          autosize: true,
          //title:'HDD usage',
          xaxis: {
              title: 'Time',
              zeroline: false
          },
          yaxis: {
              title: 'CPU Percentage %',
              showline: false
          },
          showlegend: false
        }

        var hdd_layout = {
            autosize: true,
            //title:'HDD usage',
            xaxis: {
                title: 'Time',
                zeroline: false
            },
            yaxis: {
                title: 'Disk used %',
                showline: false
            }
        }

        var mem_layout = {
            autosize: true,
            //title:'Memory usage',
            xaxis: {
                title: 'Time',
                zeroline: false
            },
            yaxis: {
                title: 'RAM Used %',
                showline: false
            }
        }

        var con_layout = {
            autosize: true,
            //title:'Connection Stats',
            xaxis: {
                title: 'Time',
                zeroline: false
            },
            yaxis: {
                title: 'Uplink Latency ms',
                showline: false
            }
        }

        function retrieve_cpudata()
        {
          Plotly.d3.csv("./static/data/cpu_percentage.csv", function(data){
            let xval = [];

            for( let i = 0; i<data.length; i++){
              let row = data[i];
              xval.push(i)
            }

            function fuckyoujs()
            {
              let key_info = [];
              for( let i=0;i<data.length;i++)
              {
                for(var key in data[i])
                {
                  if(!key_info.includes(key))
                  {
                    //console.log("Key:" + key);
                    key_info.push(key);
                  }
                  else {
                    //console.log("fuck you js");
                    return key_info; // done keys (break is unreliable and doesn't work)
                  }
                }
              }
            }

            let keys = fuckyoujs();

            let gdata_new = [];
            for( var key in keys)
            {
              gdata_new.push(
              {
                name: "core " + key,
                x: xval,
                y: [],
                mode: 'lines',
                type: 'lines'
              });
              //console.log("Added key table: " + key);
            }

            for( let i = 0; i<data.length; i++){
              let row = data[i];

              for( let keyID = 0; keyID < keys.length; keyID++)
              {
                let keyvalue = row[keys[keyID]];
                //console.log("key val: " + keyvalue);
                gdata_new[keyID].y.push(keyvalue);
              }
            }

            Plotly.newPlot('graph-cpustats', gdata_new, cpu_layout);

            });

        }

        var cpu_data = getData(100);

        //Plotly.newPlot('graph-cpustats', cpu_data, cpu_layout);
        Plotly.newPlot('graph-memstats', getData(200), mem_layout);
        Plotly.newPlot('graph-hddstats', getData(100), hdd_layout);
        Plotly.newPlot('graph-netstatus', getData(1000), net_layout);
        Plotly.newPlot('graph-tempstats', getData(40), temp_layout);
        Plotly.newPlot('graph-constats', getData(), con_layout);
        retrieve_cpudata();
        /*function updateGraphCPU()
        {
            let data = getData(100);

            // update cpu graph randomly with data
            Plotly.newPlot('graph-cpustats', data, cpu_layout);
        }*/

        //updateTimer = setInterval(updateGraphCPU,500);
    </script>
</body>
</html>
