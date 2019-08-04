#!/bin/bash

# save all env for debugging
printenv > /var/log/colony-vars-"$(basename "$BASH_SOURCE" .sh)".txt