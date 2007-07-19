; TODO finish this (use writeStream) to I don't have to be so verbose
;(syntax test-pipeline
;  (lambda (node compiler)

(printf "\n; (jitblt-compile X8B8G8R8 IN A8 OVER A8R8G8B8)\n")
[StdOut println: (jitblt-compile X8B8G8R8 IN A8 OVER A8R8G8B8)]

(printf "\n; (jitblt-compile A8B8G8R8 IN NONE OVER X8R8G8B8)\n")
[StdOut println: (jitblt-compile A8B8G8R8 IN NONE OVER X8R8G8B8)]

(printf "\n; (jitblt-compile B2G3R3 COMPONENT_IN A2B2G2R2 ATOP R5G6B5)\n")
[StdOut println: (jitblt-compile B2G3R3 COMPONENT_IN A2B2G2R2 ATOP R5G6B5)]

(printf "\n; (jitblt-compile A4B4G4R4 OUT X4A4 DEST_OVER A1R5G5B5)\n")
[StdOut println: (jitblt-compile A4B4G4R4 OUT X4A4 DEST_OVER A1R5G5B5)]

(printf "\n; (jitblt-compile A2R2G2B2 DEST_OUT A1B5G5R5 SOURCE B5G6R5)\n")
[StdOut println: (jitblt-compile A2R2G2B2 DEST_OUT A1B5G5R5 SOURCE B5G6R5)]

(printf "\n; (jitblt-compile NONE IN NONE CLEAR B5G6R5)\n")
[StdOut println: (jitblt-compile NONE IN NONE CLEAR B5G6R5)]

(printf "\n; (jitblt-compile NONE IN NONE DEST B5G6R5)\n")
[StdOut println: (jitblt-compile NONE IN NONE DEST B5G6R5)]

(printf "\n; (jitblt-compile X8B8G8R8 ADD A8 XOR A8R8G8B8)\n")
[StdOut println: (jitblt-compile X8B8G8R8 ADD A8 XOR A8R8G8B8)]

(printf "\n; (jitblt-compile B2G3R3 DEST_IN A2B2G2R2 SATURATE R5G6B5)\n")
[StdOut println: (jitblt-compile B2G3R3 DEST_IN A2B2G2R2 SATURATE R5G6B5)]

(printf "\n; (jitblt-compile SOLID OUT X4A4 DEST_OVER A1R5G5B5)\n")
[StdOut println: (jitblt-compile SOLID OUT X4A4 DEST_OVER A1R5G5B5)]

(printf "\n; (jitblt-compile B2G3R3 DEST_IN SOLID SATURATE R5G6B5)\n")
[StdOut println: (jitblt-compile B2G3R3 DEST_IN SOLID SATURATE R5G6B5)]

(printf "\n; (jitblt-compile A1B5G5R5 SOURCE NONE OVER B5G6R5)\n")
[StdOut println: (jitblt-compile A1B5G5R5 SOURCE NONE OVER B5G6R5)]
