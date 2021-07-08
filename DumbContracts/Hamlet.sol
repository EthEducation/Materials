// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

/**
 * @title Hamlet
 * @dev full description at https://anallergytoanalogy.medium.com/adventures-with-dumb-contracts-18f8ce8414c9
 */
 
contract Hamlet_event{
    event Paragraph(uint indexed num, string paragraphText);
    uint paragraphs;
    function writeParagraph(string memory paragraphText) public{
        emit Paragraph(paragraphs,paragraphText);
        paragraphs++;
    }
}
