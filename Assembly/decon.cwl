cwlVersion: v1.0
class: CommandLineTool
id: "centrifuge"
doc: "Decontaminate PacBio reads using the program centrifuge"
requirements:
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: decon:latest
inputs:
  - id: trimmedReads
    type: File
    inputBinding:
      position: 3
      prefix: -U
  - id : classificationFile
    type: File
    default: classification.txt
    inputBinding:
      position: 6
      prefix: -S
  - id : taxons
    type:
      type: array
      items: int
    inputBinding:
      position: 7
      itemSeparator: ","
      separate: true
      prefix: -t
outputs:
  - id: conReads
    type: File
    outputBinding:
      glob: "contaminatedReads.fa.gz"
  - id: deconReads
    type: File
    outputBinding:
      glob: "trimmedReads.decon.fa.gz"
baseCommand: ["/root/decon.sh"]
arguments: []
#stdout: out
