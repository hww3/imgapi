This is a simple server that provides minimal support for Joyent's IMGAPI
service. The service is read-only, and provides no means for managing
images. Images are made available by placing the manifest and zfs stream
for each image in a selected directory. 

Usage:

bin/start /path/to/images

Then, to make an image, say, corp-database-image, available, you would 
place the manifest and gzipped manifest stream in /path/to/images like
so:

/path/to/images/corp-database-image.json
/path/to/images/corp-database-image.zfs.gz

The ZFS stream must be gzipped, and the dataset (ZFS stream) and manifest 
files should be named identically, save for their extensions. Multiple
images may be hosted by adding the manifest and datasets to the data
directory. All images placed in the data directory are made available to
all requestors. To remove an image, simply remove its manifest and 
dataset files from the data directory.

Once the image has been added to the data directory, it may be queried 
and installed in the usual fashion:

imgadm source -a http://imgapi-url
imgadm avail
imgadm install image-uuid

Currently, all image manifests are scanned for each ListImages request,
so this service is perhaps not best suited for large numbers of requests
or for hosting many images. Similarly, there are no restrictions on the 
requests that may be made to this service, so appropriate precautions 
should be taken to guard agaist misuse.

TODO

- Manifest validation
- Access restrictions
- Caching of data
- Query filtering
