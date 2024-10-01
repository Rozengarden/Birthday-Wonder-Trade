from ape import *
import pytest

TOKEN_ID1=19
TOKEN_ID2=1

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

@pytest.fixture
def macci(YBC, alice):
    a = accounts["0xA8a849b09AA9bf62782AB572f09FF479B76EBaC8"]
    a.balance = 1000000000000000000000
    YBC.mintbaseExisting([alice], [TOKEN_ID1], [1], sender=a)
    YBC.mintbaseExisting([a], [TOKEN_ID2], [1], sender=a)
    return a

@pytest.fixture
def test_deposit(trade, alice, macci, YBC):
    before = YBC.balanceOf(alice, TOKEN_ID1)
    YBC.safeTransferFrom(alice, trade, TOKEN_ID1, 1, 0, sender=alice)
    assert YBC.balanceOf(alice, TOKEN_ID1) - before == -1
    assert trade.isSeeded()
    assert trade.seeder() == alice

@pytest.fixture
def test_main(test_deposit, trade, alice, macci, YBC):
    macci_before_1 = YBC.balance(macci, TOKEN_ID1)
    macci_before_2 = YBC.balance(macci, TOKEN_ID2)
    assert YBC.balance(trade.address, TOKEN_ID1) == 1
    assert YBC.balance(trade.address, TOKEN_ID2) == 0
    YBC.safeTransferFrom(macci, trade, TOKEN_ID2, 1, 0, sender=macci)
    assert YBC.balanceOf(macci, TOKEN_ID1) - macci_before_1 == 1
    assert YBC.balanceOf(macci, TOKEN_ID2) - macci_before_2 == -1
    assert YBC.balanceOf(trade, TOKEN_ID1) == 0
    assert YBC.balanceOf(trade, TOKEN_ID2) == 1
    assert trade.isSeeded()
    assert trade.seeder() == alice

def test_withdraw(test_deposit, trade, YBC, alice):
    before = YBC.balanceOf(alice, TOKEN_ID1)
    trade.withdraw(sender=alice)
    assert YBC.balanceOf(alice, TOKEN_ID1) - before == 1
    assert !trade.isSeeded()
    assert trade.seeder() == alice

# TODO:
# different erc1155 collection
# test withdraw without main & unauthorized withdraw
# test sending multiple token and batch
# test rescue function
