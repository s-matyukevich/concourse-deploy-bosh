#!/bin/bash -e

photon target set $PHOTON_URL  -c
photon target login -u $PHOTON_USER -p "$PHOTON_PASSWORD"
photon tenant set $PHOTON_TENANT 
photon project set $PHOTON_PROJECT 


## Create Photon Flavors for PCF
# 000's - ultra small VMs
# 1 cpu, 32MB memory
photon flavor list | grep "core-10 .*vm" || photon -n flavor create -n core-10 -k vm -c "vm.cpu 1 COUNT,vm.memory 32 MB"
# 100's - entry level, non-production sla only
# 1 cpu, 2GB memory, vm.cost = 1.0 baseline
photon flavor list | grep "core-100 .*vm" || photon -n flavor create -n core-100 -k vm -c "vm.cpu 1 COUNT,vm.memory 2 GB"
# 1 cpu, 4GB memory, vm.cost = 1.5 baseline
# intention is ~parity with GCE n1-standard-1 (ephemeral root)
photon flavor list | grep "core-110 .*vm" || photon -n flavor create -n core-110 -k vm -c "vm.cpu 1 COUNT,vm.memory 4 GB"
# 200's - entry level production class vm's in an HA environment
# 2 cpu, 4GB memory, vm.cost 2.0
photon flavor list | grep "core-200 .*vm" || photon -n flavor create -n core-200 -k vm -c "vm.cpu 2 COUNT,vm.memory 4 GB"
# 2 cpu, 8GB memory, vm.cost 4.0
# intention is ~parity with GCE n1-standard-2 (ephemeral root)
photon flavor list | grep "core-220 .*vm" || photon -n flavor create -n core-220 -k vm -c "vm.cpu 2 COUNT,vm.memory 8 GB"
# 4 cpu, 16GB memory, vm.cost 12.0
# intention is ~parity with GCE n1-standard-4 (ephemeral root)
photon flavor list | grep "core-240 .*vm" || photon -n flavor create -n core-240 -k vm -c "vm.cpu 4 COUNT,vm.memory 16 GB"
# 4 cpu, 32GB memory, vm.cost 20.0
photon flavor list | grep "core-245 .*vm" || photon -n flavor create -n core-245 -k vm -c "vm.cpu 4 COUNT,vm.memory 32 GB"
# 8 cpu, 32GB memory, vm.cost 25.0
# intention is ~parity with GCE n1-standard-8 (ephemeral root)
photon flavor list | grep "core-280 .*vm" || photon -n flavor create -n core-280 -k vm -c "vm.cpu 8 COUNT,vm.memory 32 GB"
# 8 cpu, 64GB memory, vm.cost 48.0
# intention is ~parity with GCE n1-standard-8 (ephemeral root)
photon flavor list | grep "core-285 .*vm" || photon -n flavor create -n core-285 -k vm -c "vm.cpu 8 COUNT,vm.memory 64 GB"
# flavor used for failure test
photon flavor list | grep "huge-vm .*vm" || photon -n flavor create -n huge-vm -k vm -c "vm.cpu 8000 COUNT,vm.memory 9000 GB"
## disks
photon flavor list | grep "pcf-2 .*ephemeral-disk" || photon -n flavor create -n pcf-2 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 2 GB"
photon flavor list | grep "pcf-4 .*ephemeral-disk" || photon -n flavor create -n pcf-4 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 4 GB"
photon flavor list | grep "pcf-20 .*ephemeral-disk" || photon -n flavor create -n pcf-20 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 20 GB"
photon flavor list | grep "pcf-100 .*ephemeral-disk" || photon -n flavor create -n pcf-100 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 100 GB"
photon flavor list | grep "pcf-16 .*ephemeral-disk" || photon -n flavor create -n pcf-16 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 16 GB"
photon flavor list | grep "pcf-32 .*ephemeral-disk" || photon -n flavor create -n pcf-32 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 32 GB"
photon flavor list | grep "pcf-64 .*ephemeral-disk" || photon -n flavor create -n pcf-64 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 64 GB"
photon flavor list | grep "pcf-128 .*ephemeral-disk" || photon -n flavor create -n pcf-128 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 128 GB"
photon flavor list | grep "pcf-256 .*ephemeral-disk" || photon -n flavor create -n pcf-256 -k ephemeral-disk -c "ephemeral-disk 1 COUNT,ephemeral-disk.capacity 256 GB"
photon flavor list | grep "core-100 .*ephemeral-disk" || photon -n flavor create -n core-100 -k ephemeral-disk -c "ephemeral-disk 1 COUNT"
photon flavor list | grep "core-200 .*ephemeral-disk" || photon -n flavor create -n core-200 -k ephemeral-disk -c "ephemeral-disk 1 COUNT"
photon flavor list | grep "core-300 .*ephemeral-disk" || photon -n flavor create -n core-300 -k ephemeral-disk -c "ephemeral-disk 1 COUNT"
photon flavor list | grep "core-100 .*persistent-disk" || photon -n flavor create -n core-100 -k persistent-disk -c "persistent-disk 1 COUNT"
photon flavor list | grep "core-200 .*persistent-disk" || photon -n flavor create -n core-200 -k persistent-disk -c "persistent-disk 1 COUNT"
photon flavor list | grep "core-300 .*persistent-disk" || photon -n flavor create -n core-300 -k persistent-disk -c "persistent-disk 1 COUNT"

