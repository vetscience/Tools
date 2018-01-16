cwlVersion: v1.0
class: CommandLineTool
id: "cleanillumina"
doc: "Clean Illumina reads using trimmomatic"
requirements:
  - $import: bowtie2-typedef.yml
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: cleanilluminape:latest
inputs:
  - id: readsPe1
    type: File[]
    inputBinding:
      prefix: "-1"
      itemSeparator: ","
      separate: true
      position: 1
  - id: readsPe2
    type: File[]
    inputBinding:
      prefix: "-2"
      itemSeparator: ","
      position: 2
  - id: phredsPe
    type: string[]
    inputBinding:
      prefix: -P
      itemSeparator: ","
      position: 3
#  - id: readsSe
#    type: ?
#      type: array
#      items: File
#    inputBinding:
#      prefix: "-s"
#      itemSeparator: ","
#      position: 4
#  - id: phredsSe
#    type: ?
#      type: array
#      items: string
#    inputBinding:
#      prefix: -S
#      itemSeparator: ","
#      position: 5
  - id: adapters
    type: File
    format: edam:format_1929  # fasta
    inputBinding:
      prefix: -a
      position: 6
  - id: leading
    type: int
    inputBinding:
      prefix: -l
      position: 7
  - id: trailing
    type: int
    inputBinding:
      prefix: -t
      position: 8
  - id: crop
    type: int?
    inputBinding:
      prefix: -c
      position: 9
  - id: headcrop
    type: int?
    default: 0
    inputBinding:
      prefix: -H
      position: 10
  - id: minlen
    type: int
    inputBinding:
      prefix: -m
      position: 11
  - id: clip
    type: string
    default: 2:30:10
    inputBinding:
      prefix: -C
      position: 12
  - id: window
    type: string
    default: 4:25
    inputBinding:
      prefix: -w
      position: 13
  - id: log
    type: string
    default: trim.log
    inputBinding:
      position: 16
      prefix: -L
outputs:
  - id: trimmedReadsPaired1
    type: File[]
    outputBinding:
      glob: "pe1.*.fastq.*"
  - id: trimmedReadsPaired2
    type: File[]
    outputBinding:
      glob: "pe2*.fastq.*"
  - id: trimmedReadsUnpaired1
    type: File[]
    outputBinding:
      glob: "unpe1.*.fastq.*"
  - id: trimmedReadsUnpaired2
    type: File[]
    outputBinding:
      glob: "unpe2*.fastq.*"
  - id: outputLog
    type: File
    outputBinding:
      glob: $(inputs.log)
#  - id: runLog
#    type: File
#    outputBinding:
#      glob: runs.sh
