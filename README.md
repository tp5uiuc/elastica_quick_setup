# Quick setup for __Elastica__

Use this script to painlessly download and install the (required) dependencies of __Elastica__
and install them on your system. By using this script you consent to install these
libraries on your system.

## Installation
Run the following commands
```bash
git clone https://github.com/tp5uiuc/elastica_quick_setup.git
cd elastica_quick_setup
# To install libraries in their default location
bash install.sh # (or zsh install.sh)
```
See [usage](#Usage) for more options

## Usage
To see the usage programmatically,
```bash
bash install.sh help # (or zsh install.sh help)
```

which prints the following message
> usage
> -----
> ./install.sh [-d dpath] [-i ipath] [-c compiler]
>
> options and explanations
> ---------------------------
>   help : Print this help message
>
>   d dpath : Path to download source of libraries (created if it does not exist).
>           Defaults to ${HOME}/Desktop/third_party/
>
>   i installpath : Path to install libraries (created if it does not exist).
>           Defaults to ${HOME}/Desktop/third_party_installed/
>
>   c compiler : C++ compiler to build/install libraries.
>           If not provided, the best known option will be chosen.
