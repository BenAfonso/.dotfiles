package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

type cpuSnapshot struct {
	idle  uint64
	total uint64
}

// readCPUStat reads /proc/stat and returns total and idle CPU times
func readCPUStat() (cpuSnapshot, error) {
	file, err := os.Open("/proc/stat")
	if err != nil {
		return cpuSnapshot{}, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "cpu ") {
			fields := strings.Fields(line)
			if len(fields) < 5 {
				return cpuSnapshot{}, fmt.Errorf("unexpected format in /proc/stat")
			}
			var total uint64 = 0
			for i := 1; i < len(fields); i++ {
				val, err := strconv.ParseUint(fields[i], 10, 64)
				if err != nil {
					return cpuSnapshot{}, err
				}
				total += val
			}
			idle, err := strconv.ParseUint(fields[4], 10, 64)
			if err != nil {
				return cpuSnapshot{}, err
			}
			return cpuSnapshot{idle: idle, total: total}, nil
		}
	}
	return cpuSnapshot{}, fmt.Errorf("cpu line not found")
}

// calculateUsage returns CPU usage percentage between two snapshots
func calculateUsage(prev, curr cpuSnapshot) int {
	deltaTotal := curr.total - prev.total
	deltaIdle := curr.idle - prev.idle
	if deltaTotal == 0 {
		return 0
	}
	usage := 100 * int(deltaTotal-deltaIdle) / int(deltaTotal)
	return usage
}

func renderBar(p int) string {
	length := 10
	normalized := p * length / 100

	str := ""
	for i := range length {
		if i < normalized {
			str += "█"
		} else {
			str += "░"
		}
	}
	return fmt.Sprintf("CPU %s %d%%", str, p)
}

func main() {
	usages := []int{}
	i := 0
	prev, _ := readCPUStat()
	go func() {
		for {
			i += 1
			curr, _ := readCPUStat()
			usage := calculateUsage(prev, curr) + 50
			prev = curr

			usages = append(usages, usage)
			if len(usages) > 5 {
				usages = usages[len(usages)-5:]
			}

			// fmt.Print("\r", usages)
			fmt.Print("\r", renderBar(usage))

			time.Sleep(time.Millisecond * 200)
		}
	}()

	select {}
}
