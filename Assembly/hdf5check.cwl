cwlVersion: cwl:v1.0
class: CommandLineTool
#baseCommand: [/root/Tools/Assembly/hdf5Check.py]
#stdout: groups.txt
requirements:
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: pakorhon/hdf5check:v1.0.2-beta
inputs:
  - id: directory
    type: Directory
    inputBinding:
      prefix: -d
      position: 1
  - id: threads
    type: int
    default: 0
    inputBinding:
      prefix: -T
      position: 2
  - id: results
    type: string
    default: Results
    inputBinding:
      prefix: -r
      position: 3
outputs:
  - id: pbFastqReads
    type: File
    outputBinding:
      glob: "*/pbReads.fastq"
