from ape import *

def main():
    sender = accounts.load("rozengarden")
    YBC = Contract(0x0Fbe8BAB2077F1c4Ef0806bFC59ed0B1799Bd9C2)
    WonderTrade = sender.deploy(project.BirthdayWonderTrade, YBC, sender=sender)
    print(f"Wonder trade contract deployed at address {WonderTrade.address}")
    YBC.safeTransferFrom(sender, WonderTrade, 19, 1, 0, sender=sender)
    print(f"Wonder trade contract is seeded by {WonderTrade.seeder}")


if __name__ == "__main__":
    main()
