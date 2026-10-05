// Load macs and T cells.
File.openSequence("/Users/pnanda/src/spatialmatch/data-raw/im-cp-workflow/", " filter=(0[1234].*[.]png)");
// New stack with only T cells.
run("Duplicate...", "title=ts duplicate range=2-4");
run("Z Project...", "projection=[Max Intensity]");
saveAs("PNG", "/Users/pnanda/src/spatialmatch/data-raw/im-cp-workflow/exp988_time22176_10_ts.png");
close;
close;
// Granuloma with macs and T cells.
run("Z Project...", "projection=[Max Intensity]");
run("Gaussian Blur...", "sigma=5");
setThreshold(257, 65535, "raw");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=500-Infinity show=Masks");
run("Grays");
saveAs("PNG", "/Users/pnanda/src/spatialmatch/data-raw/im-cp-workflow/exp988_time22176_11_gran.png");
// Exit with success.
eval("script", "System.exit(0);");