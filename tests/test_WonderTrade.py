from ape import *
import pytest

@pytest.fixture
def alice(accounts):
    a = accounts["0x02fEb744cA516FD6E41D940Ae2d0F7Cb6FCB1ac3"]
    a.balance = 1000000000000000000000
    return a

@pytest.fixture
def YBC(Contract):
    return Contract(0x0Fbe8BAB2077F1c4Ef0806bFC59ed0B1799Bd9C2)

@pytest.fixture
def trade(project, alice, YBC):
    return alice.deploy(project.BirthdayWonderTrade, YBC)

def test_main(trade, alice, YBC):
    before = YBC.balanceOf(alice, 19)
    YBC.safeTransferFrom(alice, trade, 19, 1, 0, sender=alice)
    assert before - YBC.balanceOf(alice, 19) == 1
    assert trade.isSeeded()
    assert trade.seeder() == alice

# TODO:
# test normal usage with 2 ppl
# test withdraw & unauthorized withdraw
# test sending multiple token and batch
# test rescue function
