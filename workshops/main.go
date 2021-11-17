/*
* Author ruecarlo@amazon.com
* Licensed: Apache 2.0
*/
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

const defaultIterations = 10000000

func getEnvVars() []string {
	var envVars []string

	for _, e := range os.Environ() {
		pair := strings.Split(e, "=")
		envVars = append(envVars, pair[0]+"="+pair[1])
	}

	return envVars
}

func inCircle(x, y float64) bool {
	return math.Sqrt(x*x+y*y) <= 1.0
}

func monteCarloPi(iterations int) float64 {
	source := rand.NewSource(time.Now().Unix())
	r := rand.New(source)
	var h int
	for i := 0; i <= iterations; i++ {
		if inCircle(r.Float64(), r.Float64()) {
			h++
		}
	}
	pi := 4 * float64(h) / float64(iterations)
	return pi
}



func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		res := &response{Message: "Monte-carlo pi simulation"}

		res.EnvVars = getEnvVars()

		res.Iterations = defaultIterations
		urlParams := r.URL.Query()
		if len(urlParams.Get("iterations")) == 0 {
			fmt.Printf("Iterations not passed as URL parameter, using default: %d\n",
				res.Iterations)
		} else {
			i, error := strconv.Atoi(urlParams.Get("iterations"))
			if error == nil {
				fmt.Printf("Setting iterations to: %d\n", i)
				res.Iterations = i
			} else {
				fmt.Printf("Iterations provided in the URL parameter is not a number, using default: %d\n",
					res.Iterations)
			}
		}

		fmt.Printf("Starting Monte-carlo approximation with %d iterations\n" , res.Iterations)
		res.MonteCarlo = monteCarloPi(res.Iterations)
		res.CalcDurationInSec = time.Since(start).Seconds()

		// Beautify the JSON output
		out, _ := json.MarshalIndent(res, "", "  ")

		// Normally this would be application/json, but we don't want to prompt downloads
		w.Header().Set("Content-Type", "text/plain")

		io.WriteString(w, string(out))

		fmt.Printf("Monte-carlo pi approximation [%d iterations ]completed in: %.6f seconds\n" ,
			res.Iterations,
			time.Since(start).Seconds())
	})
	http.ListenAndServe(":8080", nil)
}

type response struct {
	Message           string   `json:"message"`
	Iterations        int      `json:"iterations"`
	MonteCarlo        float64  `json:"pi"`
	CalcDurationInSec float64  `json:"duration_in_secconds"`
	EnvVars           []string `json:"env"`

}
