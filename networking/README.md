## VyOS setup

Plug VyOS firewall into `eth3` on a LAN port behind router. Run `install image` to install.

After reboot, run the following commands with VyOS plugged into the LAN on `eth3` to initially stage the network:

```
configure
set interfaces ethernet eth3 address dhcp
set service ssh port '22'
```

Then, on another machine with this repo cloned, run the firewall setup script:

```
./vyos.sh -t vyos@192.168.50.3
```
