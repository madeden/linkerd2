import PropTypes from 'prop-types';
import React from 'react';
import { withStyles } from '@material-ui/core/styles';

const styles = () => ({
  iframe: {
    border: "0px",
    height: "calc(100vh - 112px)", // 112px = Header height 64px + padding 24px * 2
    width: "100%",
  },
});

const Community = ({classes}) => {
  return (
    <iframe
      title="Community"
      src="https://linkerd.io/dashboard/"
      className={classes.iframe} />
  );
};

Community.propTypes = {
  classes: PropTypes.shape({}).isRequired,
};

export default withStyles(styles)(Community);
