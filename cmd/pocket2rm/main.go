package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	var getMaxFiles = func(key string) uint {
		val, existing := os.LookupEnv(key)
		if existing {
			u64, err := strconv.ParseUint(val, 10, 32)
			if err != nil {
				fmt.Println(err)
			}
			return uint(u64)
		} else {
			return 10
		}
	}
	var maxFiles = getMaxFiles("NUM_FETCH_ARTICLES")

	fmt.Println("start programm")
	if reloadFileExists() {
		fmt.Println("reload file exists")
	} else {
		fmt.Println("no reload file")
		if !pocketFolderExists() {
			fmt.Println("no pocket folder")
			generatePocketFolder()
		}
		generateReloadFile()
		generateFiles(maxFiles)
	}
}
