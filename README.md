# infoseek
[World of Spectrum API](https://worldofspectrum.org/) API Search Script in Bash.

World of Spectrum has a new database API that allows developers & seekers to search and retrieve information from its archive of Spectrum computer goodies.

The API is still in development at the same time as the site data is being moved to an upgraded CMS. Not all data is yet searchable through the new API.

More information about the API can be found at http://live.worldofspectrum.org/using-the-api/basics.

This Bash 'infoseek' script provides a simple way to build API queries to send to the WoS archive. This API script is flexible enough to be adapted to work with other APIs. See code comments for more information.

I wrote this script for fun on a Saturday afternoon just.. because...

# Usage

Run the script with:

```bash infoseek.sh```

Or

```./infoseek.sh```

- Read the brief welcome message. The message can be disabled in program's basic configs near the top of the script code.
- Select a search category (0 to 11)
- Select a search criteria (0 to 12)
- Enter the search query (just type away)
- Select another search criteria if required or press the Enter key with no option selected to send requests.

That's it!

Well, almost it. There are a couple of config options to be set in the script file infoseek.sh.

# Configuration

- Edit line 58 to set your own API key, if you have one.
- Edit line 61 to select the return format for the data.

The 'test' API key will return a maximum of 10 results per request.

The PHP data format is easy to read in Bash.

Other config options allow the script to be easily adapted to other APIs.

# The Future

The plan is to add:

- Command line arguments
- An output parser
- Configuration to select what to do with the returned data e.g. add to file, send to browser etc...
- Option to work with multipl API URLs simultaneously

This script will be updated as WoS adds new criteria and features to the API.

# Changelog

1.0.1

- Modified configs to make the script more generic (e.g. added username and password option).
- Added option to disable the welcome message.
- Modifed the message/prompt texts.

1.0.0

- First public release
