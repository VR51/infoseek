# infoseek
[World of Spectrum API](https://worldofspectrum.org/) Search Script in Bash.

World of Spectrum has a new database API that allows developers & seekers to search and retrieve information from its archive of Spectrum computer goodies.

The API is still in development at the same time as the site data is being moved to an upgraded CMS. Not all data is yet searchable through the new API.

More information about the API can be found at http://live.worldofspectrum.org/using-the-api/basics.

This Bash 'infoseek' script provides a simple way to build API queries to send to the WoS archive.

# Usage

Run the script with:

```bash infoseek.sh```

Or

```./infoseek.sh```

- Read the welcome message (you can comment out the welcome message lines 100, 101, 102 and 103 if you like).
- Select a search category (0 to 11)
- Select a search criteria (0 to 12)
- Enter the search query (just type away)
- Select another search criteria if required or press the Enter key to send the requests.

That's it!

Well, almost it. There are 2 config options to be set in the script file infoseek.sh.

# Configuration

- Edit line 49 to set your API key.
- Edit line 50 to select the return format for the data.

The 'test' API key will return a maximum of 10 results per request.

The PHP data format is easy to read

# The Future

The plan is to add:

- Command line arguments
- An output parser
- Configuration to select what to do with the returned data e.g. add to file, send to browser etc...

This script will be updated as WoS adds new criteria and features to the API.
