//
//  SearchResultCell.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 23/07/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
  
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
}
