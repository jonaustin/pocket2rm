package main

import (
	"fmt"
)

func main() {
	fmt.Println("start program")

	//var getMaxFiles = func(key string) uint {
	//  val, existing := os.LookupEnv(key)
	//  if existing {
	//    maxFiles, err := strconv.ParseInt(val, 10, 64)
	//    if err != nil {
	//      fmt.Println(err)
	//    }
	//    return uint(maxFiles)
	//  }

	//  return 10
	//}
	//var maxFiles = getMaxFiles("NUM_FETCH_ARTICLES")

	if reloadFileExists() {
		fmt.Println("reload file exists")
	} else {
		fmt.Println("no reload file")
		if !pocketFolderExists() {
			fmt.Println("no pocket folder")
			generatePocketFolder()
		}
		generateReloadFile()
		//generateFiles(maxFiles)
		generateFiles()
	}
}
