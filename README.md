# 3d printing calculator

Based on Slic3r and Printrun

However you can easily add your own APIs to this app

## Install

Just run ``installdeps.sh``, it will download and install all project dependencies


## Configure

sudo nano 3dcalculator.conf:

```

{
  hypnotoad => {
    listen  => ['http://*:8090'],
  },
  paths => {
    default_slic3r_config  => 'examples/config.ini',
    temp_gcode_file => 'test.g',
    slic3r_api => '/opt/cnc/Slic3r/slic3r.pl',
    printrun => 'Printrun/pronsole.py',
    stl_tmp => 'files'
  },
  paths_type => 'relative',
  paths_always_full => [ 'slic3r_api' ],
  costs => {
     kg => 2000,  # roubles (or in any local currency )
     kWh => 5, # roubles (or in any local currency )
     consumption => 360, # W
     amortization_per_hour => 0.02, # roubles
     money_per_g => 8,
     min_price => 100
  },
  default_plastic_type => "PLA",
  plastic_density => 1.25, # g/cm3
  telegram => {
    token => '',
    owner_id => '',
    async => 0
  }
};

```

###  3dcalculator.conf tips and tricks 


All variables in paths must be full

```
paths => {
    default_slic3r_config  => '/home/pavel/test/config.ini',
    temp_gcode_file => '/home/pavel/test/test.gcode',
    path_to_slic3r_api => '/opt/cnc/Slic3r/slic3r.pl',
  },
```

Also or you can use relative paths if you set ``paths_type => 'relative'``
In this case app will add ``pwd`` prefix to all values of paths hash, excluding those
ones which specified at ``paths_always_full`` array

```
 paths => {
    default_slic3r_config  => 'examples/config.ini',
    temp_gcode_file => 'test.g',
    path_to_slic3r_api => '/opt/cnc/Slic3r/slic3r.pl',
  },
  paths_type => 'relative',
  paths_always_full => [ 'path_to_slic3r_api' ],
```


If you will set `$config->costs->min_price = 0 you will get prime cost


## How to run the app ?

### Start/stop to debug

morbo 3dcalculator

### Start/stop at deployment server

hypnotoad 3dcalculator
hypnotoad 3dcalculator --stop


### Backend API

Example of API reply

```javascript
{

    "stl": {
        "pla_weight_g": 2.125,
        "volume_cm3": 1.7
    },
    "expected_print_time": {
        "printrun": {
            "hours": 0.22,
            "time_str": "0:13:07"
        }
    },
    "price": 100

}
```

Main method is ``customer_api``


### Frontend API

index.html.ep

POST /upload

param: model

```html

%= form_for upload => (enctype => 'multipart/form-data', ) => begin
				      		%= file_field 'model'

				      		<div class="row" style="margin-top:50px;">
				      		<button type="submit" class="btn btn-lg btn-success btn-block">Поехали!</button>
				      		</div>				      		
			    		% end
```			    		


adjust.html.ep

Also using https://metacpan.org/pod/Mojolicious::Plugin::TagHelpers


## F.A.Q. for developers

### What to do if you can't install Slic3r-XS on your server

https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04

### How does the log from Slic3r command line looks like?

```
pavel@pavel-Inspiron-3542:/opt/cnc/Slic3r$ perl /opt/cnc/Slic3r/slic3r.pl --load /home/pavel/projects/fablab_calc/examples/config.ini --output /home/pavel/projects/fablab_calc/test.g  /home/pavel/projects/fablab_calc/examples/keychain.stl
=> Processing triangulated mesh
=> Generating perimeters
=> Preparing infill
=> Infilling layers
=> Generating skirt
=> Exporting G-code to /home/pavel/projects/fablab_calc/test.g
Done. Process took 0 minutes and 1.007 seconds
Filament required: 698.3mm (1.7cm3)
```

### How does the log from Printrun command line looks like?

```
pavel@pavel-Inspiron-3542:~/projects/fablab_calc$ echo "load /home/pavel/projects/fablab_calc/test.g" | /home/pavel/projects/fablab_calc/Printrun/pronsole.py
WARNING:root:Memory-efficient GCoder implementation unavailable: No module named gcoder_line
Welcome to the printer console! Type "help" for a list of available commands.
offline> Loading file: /home/pavel/projects/fablab_calc/test.g
Loaded /home/pavel/projects/fablab_calc/test.g, 11605 lines.
Estimated duration: 24 layers, 0:13:07
offline> 
[ERROR] Not connected to printer.
Disconnecting from printer...
Exiting program. Goodbye!
```

### How to setup Telegram Webhooks

For your convenience you can just run `generate_keys.sh`

```
openssl genrsa -out secret.key 2048
openssl req -new -sha256 -key secret.key -out crt.csr
openssl x509 -req -days 365 -in crt.csr -signkey secret.key -out server.crt
openssl x509 -text -noout -in server.crt
```

Firstly you need to setup that your app works via https. Here is setup for nginx

```
upstream 3dcalcbot {
  server 127.0.0.1:8083;
}

server {
    listen 443 ssl;
    server_name 3d.fablab61.ru www.3d.fablab61.ru;
    ssl_certificate /home/3dcalc/https/server.crt;
    ssl_certificate_key /home/3dcalc/https/secret.key;
    root /home/3dcalc;
    client_max_body_size 2M;

  location / {
    proxy_pass http://3dcalcbot;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```


### What if app doesn't work?

#### Regexp doesn't work anymore

1. Check "Running Slic3r" and "Running Printrun" strings in cosnsole (`app->log->info ...` in app).
Run them manually to see is there any changes in output.

#### Check permissions

Check permissions to /files and /log folders

