# part1

## build

```
./build_p1.sh
```

## run

* `CRYSTAL_WORKERS` = choose number of workers (probably number of available cores)
* `-f FILENAME` = file to process

```
CRYSTAL_WORKERS=12 ./day5p1 -f input.txt
```

The above runs in about 34 seconds on my 8-core (16t) i9

## developing


```
crystal day5p1.cr -- -f test_input.txt
```

in a change loop:
```
watchman-make -p '**/*.cr' --run='crystal day5p1.cr -- -f test_input.txt'
```

# part2

## build

```
./build_p2.sh
```
