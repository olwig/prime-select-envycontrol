# prime-select-envycontrol

Compatibility wrapper that provides a `prime-select` interface using
`envycontrol` for the TUXEDO Control Center.

## Motivation

The intention of this project was to enable the GPU switching options in
the TUXEDO Control Center tray icon on Arch-based distributions.\
Since the Control Center expects Ubuntu's `prime-select` from
`nvidia-prime`, these options normally do not appear on distributions
that do not ship it.

This wrapper provides a compatible `prime-select` command that
internally uses `envycontrol`.

## Related Projects

-   https://github.com/canonical/nvidia-prime
-   https://github.com/bayasdev/envycontrol
-   https://github.com/tuxedocomputers/tuxedo-control-center

## How it works

The wrapper exposes the `prime-select` CLI and forwards commands to
`envycontrol`.

  prime-select   envycontrol
  -------------- ---------------------
  intel          --switch integrated
  nvidia         --switch nvidia
  on-demand      --switch hybrid
  query          envycontrol --query

Additionally the file

`/var/lib/ubuntu-drivers-common/requires_offloading`

must exist so the TUXEDO Control Center detects offloading support.

## Requirements

-   NVIDIA drivers
-   envycontrol
-   TUXEDO Control Center

## Installation

Install the wrapper:

``` bash
sudo install -m 755 prime-select /usr/local/bin/prime-select
```

Create the offloading marker:

``` bash
sudo mkdir -p /var/lib/ubuntu-drivers-common
sudo touch /var/lib/ubuntu-drivers-common/requires_offloading
```

## Usage

Query mode:

``` bash
prime-select query
```

Switch GPU:

``` bash
sudo prime-select intel
sudo prime-select nvidia
sudo prime-select on-demand
```

Internally these commands are translated to `envycontrol`.
