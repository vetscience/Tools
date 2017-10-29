cwlVersion: cwl:v1.0
class: CommandLineTool
baseCommand: [/root/Tools/orthoMcl]
#stdout: groups.txt
requirements:
  - class: InlineJavascriptRequirement
#  - class: ShellCommandRequirement
hints:
  - class: DockerRequirement
    dockerPull: pakorhon/orthomcl:v1.0.2-beta
inputs:
  - id: directory
    type: Directory
    inputBinding:
      prefix: -d
      position: 1
  - id: fastas
    type:
      type: array
      items: string
    inputBinding:
      prefix: -i
      itemSeparator: ","
      separate: true
      position: 2
  - id: labels
    type:
      type: array
      items: string
    inputBinding:
      prefix: -l
      itemSeparator: ","
      separate: true
      position: 3
  - id: positions
    type:
      type: array
      items: int
    inputBinding:
      prefix: -p
      itemSeparator: ","
      separate: true
      position: 4
  - id: threads
    type: int
    inputBinding:
      prefix: -T
      position: 5
  - id: evalue
    type: float
    default: 1e-5
    inputBinding:
      prefix: -e
      position: 6
  - id: similarity
    type: float
    default: 0.5
    inputBinding:
      prefix: -s
      position: 7
  - id: minlength
    type: int
    default: 20
    inputBinding:
      prefix: -m
      position: 8
  - id: skipblast
    type: boolean
    default: false
    inputBinding:
      prefix: -b
      position: 9
  - id: mysqlip
    type: string
    inputBinding:
      prefix: -a
      position: 10
outputs:
  - id: orthologs
    type:
      type: array
      items: [File, Directory]
    outputBinding:
      glob: "*"
