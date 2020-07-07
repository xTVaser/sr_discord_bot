import discord
from discord.ext import commands
import random
import os

token = os.getenv("TOKEN")

bot = commands.Bot(command_prefix="$")
bot.remove_command("help")


@bot.event
async def on_ready():
    print("Logged in as")
    print(bot.user.name)
    print(bot.user.id)
    print("------")
    activity = discord.Game(name="$help")
    await bot.change_presence(status=discord.Status.idle, activity=activity)


@bot.command()
async def help(ctx):
    """Help Command."""
    embedVar = discord.Embed(
        title="Bot Information",
        description="The bot at this point is abandoned and will be replaced by something much better, hopefully soon.  It will continue to announce streams, and that is it.",
        color=0xFFFFFE,  # discord.py seems to struggle with #FFFFFF color
        url="http://www.github.com/xTVaser/sr_discord_bot",
    )
    embedVar.set_author(
        name="xTVaser",
        url="https://github.com/xTVaser",
        icon_url="https://avatars0.githubusercontent.com/u/13153231?s=460&v=4",
    )
    embedVar.set_thumbnail(
        url="https://raw.githubusercontent.com/xTVaser/sr_discord_bot/master/assets/author_icon.png"
    )
    embedVar.set_footer(text="$help to view a list of available commands")
    await ctx.send(embed=embedVar)


currently_streaming = {}


@bot.event
async def on_member_update(before, after):
    allowed_game_list = ["jak", "daxter"]
    stream_channel_id = 215655895202398209
    streamer_role = 208395430130614272
    exclude_keywords = ["nosrl"]
    try:
        # Verify they are a streamer
        if not any(role.id == streamer_role for role in after.roles):
            return

        stream = None

        # find the streaming activity
        for activity in after.activities:
            if activity.type == ActivityType.streaming:
                stream = activity
                break

        if stream == None:
            if after.id in currently_streaming and currently_streaming[after.id]:
                del currently_streaming[after.id]
            return

        # Check to see if they are streaming a game thats worth announcing
        if stream.game.lower() not in allowed_game_list:
            return
        # Check to see if their title should exclude announcments
        for keyword in exclude_keywords:
            if keyword in stream.name.lower():
                return

        embedVar = discord.Embed(
            title="%s Just Started Streaming" % after.display_name,
            description="The bot at this point is abandoned and will be replaced by something much better, hopefully soon.  It will continue to announce streams, and that is it.",
            color=0x6441A4,
            url=stream.url,
        )
        embedVar.set_author(
            name="Stream Notification",
            url=stream.url,
            icon_url="https://raw.githubusercontent.com/xTVaser/sr_discord_bot/master/assets/author_icon.png",
        )
        embedVar.set_thumbnail(url=after.avatar_url)
        embedVar.add_field(name="Stream Title", value=stream.name)
        embedVar.add_field(name="Game Name", value=stream.game)
        channel = bot.get_channel(stream_channel_id)
        await channel.send(embed=embedVar)
        currently_streaming[after.id] = True
    except Exception as e:
        print(e)


bot.run(token)
