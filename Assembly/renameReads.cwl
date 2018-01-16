cwlVersion: v1.0
class: CommandLineTool
id: "centrifuge"
doc: "Decontaminate PacBio reads using the program centrifuge"
requirements:
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: renamereads:latest
inputs:
  - id: trimmedReads
    type: File
    inputBinding:
      position: 1
      prefix: -U
outputs:
  - id: renamedReads
    type: File
    outputBinding:
      glob: "*"
baseCommand: ["/root/renamereads.sh"]
arguments: []
#stdout: out
